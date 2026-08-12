//
//  HTTPClient.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/06/04.
//

import Foundation

actor HTTPClient {

    private let config: SdkConfig
    private let sessionProvider: SessionProvider
    private let logger: NetworkLogger
    private let session: URLSession
    private var refreshTask: Task<Void, Error>?

    init(config: SdkConfig, sessionProvider: SessionProvider, session: URLSession? = nil) {
        self.config = config
        self.sessionProvider = sessionProvider
        self.logger = NetworkLogger(isEnabled: config.enableLogging)
        if let session {
            self.session = session
        } else {
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForRequest = 60.0
            sessionConfig.timeoutIntervalForResource = 60.0
            sessionConfig.waitsForConnectivity = true
            sessionConfig.httpMaximumConnectionsPerHost = 5
            sessionConfig.requestCachePolicy = .useProtocolCachePolicy
            self.session = URLSession(configuration: sessionConfig)
        }
    }

    func fetch<T: Decodable>(
        endpoint: Endpoints,
        method: HTTPMethod = .GET,
        parameters: [String: String]? = nil,
        body: Encodable? = nil,
        id: String? = nil,
        requiresAuth: Bool = true,
        isRetry: Bool = false
    ) async throws -> T {
        let url = try constructURL(endpoint: endpoint, id: id, parameters: parameters)
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        if let body {
            if endpoint == .auth {
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                if let dict = body as? [String: String] {
                    let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "~-_."))
                    let encoded = dict.map {
                        "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: allowed) ?? $0.value)"
                    }.joined(separator: "&")
                    request.httpBody = encoded.data(using: .utf8)
                }
            } else {
                request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                let encoder = JSONEncoder()
                request.httpBody = try encoder.encode(AnyEncodable(body))
            }
        }

        try await addHeaders(to: &request, requiresAuth: requiresAuth, forceBasicAuth: endpoint == .auth)

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
               !isRetry {
                let staleAccessToken = request.value(forHTTPHeaderField: "Authorization")
                    .flatMap { $0.hasPrefix("Bearer ") ? String($0.dropFirst(7)) : nil }
                return try await handleTokenRefreshAndRetry(
                    endpoint: endpoint, method: method, parameters: parameters,
                    body: body, id: id, staleAccessToken: staleAccessToken
                )
            }

            guard (200..<300).contains(httpResponse.statusCode) else {
                if endpoint == .auth,
                   let serverError = try? JSONDecoder().decode(ServerErrorResponse.self, from: data) {
                    throw SdkError.networkError(
                        statusCode: httpResponse.statusCode,
                        message: serverError.errorDescription ?? serverError.error ?? "Authentication failed"
                    )
                }
                if let apiError = try? JSONDecoder().decode(ApiErrorResponse.self, from: data) {
                    throw SdkError.networkError(
                        statusCode: httpResponse.statusCode,
                        message: apiError.message ?? apiError.detail ?? apiError.error ?? "Unknown error"
                    )
                }
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
            urlString += "/\(id)"
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

    private func addHeaders(to request: inout URLRequest, requiresAuth: Bool, forceBasicAuth: Bool = false) async throws {
        if requiresAuth, sessionProvider.getAuthState().isExpired, sessionProvider.getRefreshToken() != nil {
            try await serializedRefresh(staleAccessToken: nil)
        }

        if !forceBasicAuth, let token = sessionProvider.getAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
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

    private func serializedRefresh(staleAccessToken: String?) async throws {
        if let inFlight = refreshTask {
            _ = try? await inFlight.value
            return try await serializedRefresh(staleAccessToken: staleAccessToken)
        }

        if let staleAccessToken {
            if let currentAccessToken = sessionProvider.getAccessToken(),
               !currentAccessToken.isEmpty,
               currentAccessToken != staleAccessToken {
                return
            }
        } else if !sessionProvider.getAuthState().isExpired {
            return
        }

        guard let refreshToken = sessionProvider.getRefreshToken() else {
            sessionProvider.onAuthenticationFailed()
            throw SdkError.authenticationRequired
        }

        let task = Task {
            defer { self.refreshTask = nil }
            try await self.executeRefresh(refreshToken: refreshToken)
        }
        refreshTask = task
        try await task.value
    }

    private func executeRefresh(refreshToken: String) async throws {
        let tokenBody: [String: String] = [
            "grant_type": "refresh_token",
            "refresh_token": refreshToken
        ]

        let response: SignInCustomerResponse
        do {
            response = try await fetch(
                endpoint: .auth,
                method: .POST,
                body: tokenBody,
                requiresAuth: false
            )
        } catch let error as SdkError {
            if case .networkError(let statusCode, _) = error,
               statusCode == 400 || statusCode == 401 || statusCode == 403 {
                sessionProvider.onAuthenticationFailed()
                throw SdkError.authenticationRequired
            }
            throw error
        }

        let expiresAt = Date().addingTimeInterval(TimeInterval(response.tokenExpiresIn))
        try sessionProvider.saveAuthState(.authenticated(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken ?? refreshToken,
            expiresAt: expiresAt
        ))
        sessionProvider.onTokenRefreshed(response: response)
    }

    private func handleTokenRefreshAndRetry<T: Decodable>(
        endpoint: Endpoints,
        method: HTTPMethod,
        parameters: [String: String]?,
        body: Encodable?,
        id: String?,
        staleAccessToken: String?
    ) async throws -> T {
        try await serializedRefresh(staleAccessToken: staleAccessToken)

        return try await fetch(
            endpoint: endpoint,
            method: method,
            parameters: parameters,
            body: body,
            id: id,
            requiresAuth: true,
            isRetry: true
        )
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
