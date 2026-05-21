import Foundation

final class HTTPClient {

    private let config: SdkConfig
    private let sessionProvider: SessionProvider
    private let logger: NetworkLogger
    private let session: URLSession
    private var isRefreshing = false

    init(config: SdkConfig, sessionProvider: SessionProvider) {
        self.config = config
        self.sessionProvider = sessionProvider
        self.logger = NetworkLogger(isEnabled: config.enableLogging)
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        sessionConfig.timeoutIntervalForResource = 60.0
        sessionConfig.waitsForConnectivity = true
        sessionConfig.httpMaximumConnectionsPerHost = 5
        sessionConfig.requestCachePolicy = .useProtocolCachePolicy
        self.session = URLSession(configuration: sessionConfig)
    }

    func fetch<T: Decodable>(
        endpoint: Endpoints,
        method: HTTPMethod = .GET,
        parameters: [String: String]? = nil,
        body: Encodable? = nil,
        id: String? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        let url = try constructURL(endpoint: endpoint, id: id, parameters: parameters)
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        if let body {
            if endpoint == .auth {
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                if let dict = body as? [String: String] {
                    let encoded = dict.map {
                        "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? $0.value)"
                    }.joined(separator: "&")
                    request.httpBody = encoded.data(using: .utf8)
                }
            } else {
                request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                let encoder = JSONEncoder()
                request.httpBody = try encoder.encode(AnyEncodable(body))
            }
        }

        try await addHeaders(to: &request, requiresAuth: requiresAuth)

        logger.logRequest(method: method.rawValue, url: url.absoluteString, headers: request.allHTTPHeaderFields, body: request.httpBody)
        let start = Date()

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw SdkError.unknown(URLError(.badServerResponse))
            }

            logger.logResponse(
                method: method.rawValue,
                url: url.absoluteString,
                statusCode: httpResponse.statusCode,
                duration: Date().timeIntervalSince(start),
                body: data
            )

            if (httpResponse.statusCode == 401 || httpResponse.statusCode == 403),
               requiresAuth,
               !isRefreshing {
                return try await handleTokenRefreshAndRetry(
                    endpoint: endpoint, method: method, parameters: parameters,
                    body: body, id: id
                )
            }

            guard (200..<300).contains(httpResponse.statusCode) else {
                let message = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw SdkError.networkError(statusCode: httpResponse.statusCode, message: message)
            }

            do {
                let decoder = JSONDecoder()
                return try decoder.decode(T.self, from: data)
            } catch {
                throw SdkError.decodingError(error)
            }
        } catch let error as SdkError {
            throw error
        } catch {
            logger.logError(method: method.rawValue, url: url.absoluteString, error: error)
            throw SdkError.unknown(error)
        }
    }

    // MARK: - Private

    private func constructURL(
        endpoint: Endpoints,
        id: String?,
        parameters: [String: String]?
    ) throws -> URL {
        let base = config.baseURL
        let pathPrefix = endpoint.rawValue.starts(with: "auth/") ? "/" : "/api/\(config.apiVersion)/"

        var path = endpoint.rawValue
        if let id, path.contains("placeholder") {
            path = path.replacingOccurrences(of: "placeholder", with: id)
        }

        var urlString = base + pathPrefix + path

        if let id, !endpoint.rawValue.contains("placeholder") {
            urlString += "/\(id)/"
        } else if !urlString.hasSuffix("/") {
            urlString += "/"
        }

        guard var components = URLComponents(string: urlString) else {
            throw SdkError.invalidURL
        }

        if let parameters, !parameters.isEmpty {
            components.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        guard let url = components.url else {
            throw SdkError.invalidURL
        }

        return url
    }

    private func addHeaders(to request: inout URLRequest, requiresAuth: Bool) async throws {
        if requiresAuth, let token = sessionProvider.getAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else if !requiresAuth {
            let credentials = "\(config.clientId):\(config.clientSecret)"
            if let data = credentials.data(using: .utf8) {
                request.setValue("Basic \(data.base64EncodedString())", forHTTPHeaderField: "Authorization")
            }
        }

        if !config.awsWafToken.isEmpty {
            request.setValue(config.awsWafToken, forHTTPHeaderField: "x-auth-validation")
        }

        if let customHeaders = await config.customHeadersProvider?() {
            for (key, value) in customHeaders {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
    }

    private func handleTokenRefreshAndRetry<T: Decodable>(
        endpoint: Endpoints,
        method: HTTPMethod,
        parameters: [String: String]?,
        body: Encodable?,
        id: String?
    ) async throws -> T {
        isRefreshing = true
        defer { isRefreshing = false }

        guard let refreshToken = sessionProvider.getRefreshToken() else {
            throw SdkError.authenticationRequired
        }

        let tokenBody: [String: String] = [
            "grant_type": "refresh_token",
            "refresh_token": refreshToken
        ]

        let tokenResponse: TokenResponse = try await fetch(
            endpoint: .auth,
            method: .POST,
            body: tokenBody,
            requiresAuth: false
        )

        let expiresAt = Date().addingTimeInterval(TimeInterval(tokenResponse.expiresIn))
        try sessionProvider.saveAuthState(.authenticated(
            accessToken: tokenResponse.accessToken,
            refreshToken: tokenResponse.refreshToken ?? refreshToken,
            expiresAt: expiresAt
        ))

        return try await fetch(
            endpoint: endpoint,
            method: method,
            parameters: parameters,
            body: body,
            id: id,
            requiresAuth: true
        )
    }
}

// MARK: - Internal token response model

struct TokenResponse: Decodable {
    let accessToken: String
    let refreshToken: String?
    let expiresIn: Int
    let tokenType: String?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case tokenType = "token_type"
    }
}

// MARK: - Type-erased Encodable wrapper

struct AnyEncodable: Encodable {
    private let encode: (Encoder) throws -> Void

    init(_ wrapped: Encodable) {
        self.encode = wrapped.encode
    }

    func encode(to encoder: Encoder) throws {
        try encode(encoder)
    }
}
