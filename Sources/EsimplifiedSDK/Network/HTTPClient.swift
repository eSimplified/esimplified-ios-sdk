//
//  HTTPClient.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/06/04.
//

import Foundation

#if DEBUG
/// DEBUG-only delegate that trusts self-signed certs for the dev environment host
/// (Traefik default cert until a real cert is provisioned). Strict TLS for every
/// other host. Compiled out of release builds.
private final class DevTrustOverrideDelegate: NSObject, URLSessionDelegate {

    private static let trustedHostSuffixes: [String] = [
        "knowroaming.api.dev.esimplified.io",
        ".api.dev.esimplified.io"
    ]

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        let host = challenge.protectionSpace.host
        let method = challenge.protectionSpace.authenticationMethod
        print("🔐 DEV-TRUST: challenge host=\(host) method=\(method)")
        guard
            method == NSURLAuthenticationMethodServerTrust,
            let serverTrust = challenge.protectionSpace.serverTrust,
            Self.trustedHostSuffixes.contains(where: { host == $0 || host.hasSuffix($0) })
        else {
            print("🔐 DEV-TRUST: falling through to default for host=\(host)")
            completionHandler(.performDefaultHandling, nil)
            return
        }
        print("🔐 DEV-TRUST: ACCEPTING self-signed cert for host=\(host)")
        completionHandler(.useCredential, URLCredential(trust: serverTrust))
    }
}
#endif

actor HTTPClient {

    private let config: SdkConfig
    private let sessionProvider: SessionProvider
    private let logger: NetworkLogger
    private let session: URLSession
    private var isRefreshing = false

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
            #if DEBUG
            if config.environment == .dev {
                print("🔐 HTTPClient: initializing with DevTrustOverrideDelegate (env=.dev, baseURL=\(config.baseURL))")
                self.session = URLSession(
                    configuration: sessionConfig,
                    delegate: DevTrustOverrideDelegate(),
                    delegateQueue: nil
                )
            } else {
                print("🔐 HTTPClient: initializing WITHOUT trust override (env != .dev, baseURL=\(config.baseURL))")
                self.session = URLSession(configuration: sessionConfig)
            }
            #else
            self.session = URLSession(configuration: sessionConfig)
            #endif
        }
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
               !isRefreshing {
                return try await handleTokenRefreshAndRetry(
                    endpoint: endpoint, method: method, parameters: parameters,
                    body: body, id: id
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
            if let urlError = error as? URLError {
                print("🌐 URLError code=\(urlError.code.rawValue) (.\(String(describing: urlError.code))) desc=\(urlError.localizedDescription) failingURL=\(urlError.failingURL?.absoluteString ?? "nil") underlying=\(urlError.errorUserInfo[NSUnderlyingErrorKey].debugDescription)")
            } else {
                print("🌐 Non-URL error type=\(type(of: error)) desc=\(error.localizedDescription)")
            }
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
        // Proactive token refresh — check if token is near expiry (5 min buffer)
        if requiresAuth {
            let state = sessionProvider.getAuthState()
            if state.isExpired, !isRefreshing {
                if let refreshToken = sessionProvider.getRefreshToken() {
                    try await performTokenRefresh(refreshToken: refreshToken)
                }
            }
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

    private func performTokenRefresh(refreshToken: String) async throws {
        isRefreshing = true
        defer { isRefreshing = false }

        let tokenBody: [String: String] = [
            "grant_type": "refresh_token",
            "refresh_token": refreshToken
        ]

        do {
            let response: SignInCustomerResponse = try await fetch(
                endpoint: .auth,
                method: .POST,
                body: tokenBody,
                requiresAuth: false
            )

            let expiresAt = Date().addingTimeInterval(TimeInterval(response.tokenExpiresIn))
            try sessionProvider.saveAuthState(.authenticated(
                accessToken: response.accessToken,
                refreshToken: response.refreshToken ?? refreshToken,
                expiresAt: expiresAt
            ))
            sessionProvider.onTokenRefreshed(response: response)
        } catch {
            sessionProvider.onAuthenticationFailed()
            throw SdkError.authenticationRequired
        }
    }

    private func handleTokenRefreshAndRetry<T: Decodable>(
        endpoint: Endpoints,
        method: HTTPMethod,
        parameters: [String: String]?,
        body: Encodable?,
        id: String?
    ) async throws -> T {
        guard let refreshToken = sessionProvider.getRefreshToken() else {
            sessionProvider.onAuthenticationFailed()
            throw SdkError.authenticationRequired
        }

        try await performTokenRefresh(refreshToken: refreshToken)

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
