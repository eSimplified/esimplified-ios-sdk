//
//  TokenRefreshSerializationTests.swift
//  EsimplifiedSDK
//

import Testing
import Foundation
@testable import EsimplifiedSDK

final class SingleUseTokenServer: @unchecked Sendable {

    private let lock = NSLock()
    private var validAccessTokens: Set<String>
    private var currentRefreshToken: String
    private var consumedRefreshTokens: Set<String> = []
    private var issueCounter = 0
    private var tokenEndpointCallCount = 0
    private let refreshDelay: TimeInterval

    init(validAccessTokens: Set<String> = [], refreshToken: String, refreshDelay: TimeInterval = 0) {
        self.validAccessTokens = validAccessTokens
        self.currentRefreshToken = refreshToken
        self.refreshDelay = refreshDelay
    }

    var tokenEndpointCalls: Int {
        lock.lock(); defer { lock.unlock() }
        return tokenEndpointCallCount
    }

    func handler(successJson: String) -> MockURLProtocol.Handler {
        { [self] request in
            guard let url = request.url else { throw URLError(.badURL) }

            if url.path.contains("/auth/token") {
                let bodyData = Self.readBody(from: request)
                let submittedToken = Self.refreshTokenValue(fromFormBody: bodyData)

                lock.lock()
                tokenEndpointCallCount += 1
                let isConsumed = submittedToken.map { consumedRefreshTokens.contains($0) } ?? true
                let isCurrent = submittedToken == currentRefreshToken

                guard let submittedToken, isCurrent, !isConsumed else {
                    lock.unlock()
                    let response = HTTPURLResponse(url: url, statusCode: 400, httpVersion: "HTTP/1.1", headerFields: ["Content-Type": "application/json"])!
                    let body = #"{"error":"invalid_grant","error_description":"refresh token consumed"}"#
                    return (response, body.data(using: .utf8))
                }

                consumedRefreshTokens.insert(submittedToken)
                issueCounter += 1
                let newAccessToken = "access-\(issueCounter)"
                let newRefreshToken = "refresh-\(issueCounter)"
                currentRefreshToken = newRefreshToken
                validAccessTokens.insert(newAccessToken)
                let delay = refreshDelay
                lock.unlock()

                if delay > 0 {
                    Thread.sleep(forTimeInterval: delay)
                }

                let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["Content-Type": "application/json"])!
                let body = #"{"access_token":"\#(newAccessToken)","expires_in":3600,"token_type":"Bearer","scope":"all","refresh_token":"\#(newRefreshToken)"}"#
                return (response, body.data(using: .utf8))
            }

            let bearer = request.value(forHTTPHeaderField: "Authorization")?.replacingOccurrences(of: "Bearer ", with: "")
            lock.lock()
            let isValid = bearer.map { validAccessTokens.contains($0) } ?? false
            lock.unlock()

            guard isValid else {
                let response = HTTPURLResponse(url: url, statusCode: 401, httpVersion: "HTTP/1.1", headerFields: nil)!
                return (response, nil)
            }

            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["Content-Type": "application/json"])!
            return (response, successJson.data(using: .utf8))
        }
    }

    private static func readBody(from request: URLRequest) -> Data? {
        if let body = request.httpBody { return body }
        guard let stream = request.httpBodyStream else { return nil }
        stream.open()
        defer { stream.close() }
        var data = Data()
        let bufferSize = 1024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer { buffer.deallocate() }
        while stream.hasBytesAvailable {
            let read = stream.read(buffer, maxLength: bufferSize)
            if read <= 0 { break }
            data.append(buffer, count: read)
        }
        return data
    }

    private static func refreshTokenValue(fromFormBody data: Data?) -> String? {
        guard let data, let body = String(data: data, encoding: .utf8) else { return nil }
        for pair in body.components(separatedBy: "&") {
            let parts = pair.components(separatedBy: "=")
            if parts.count == 2, parts[0] == "refresh_token" {
                return parts[1].removingPercentEncoding ?? parts[1]
            }
        }
        return nil
    }
}

final class SaveThrowingSessionProvider: SessionProvider, @unchecked Sendable {

    private let lock = NSLock()
    private var state: AuthState
    private(set) var authenticationFailedCalls = 0

    init(initial: AuthState) {
        self.state = initial
    }

    func saveAuthState(_ state: AuthState) throws {
        throw NSError(domain: "keychain", code: -25299)
    }

    func getAuthState() -> AuthState {
        lock.lock(); defer { lock.unlock() }
        return state
    }

    func getAccessToken() -> String? {
        lock.lock(); defer { lock.unlock() }
        return state.accessToken
    }

    func getRefreshToken() -> String? {
        lock.lock(); defer { lock.unlock() }
        return state.refreshToken
    }

    func clearSession() throws {}

    func onTokenRefreshed(response: SignInCustomerResponse) {}

    func onAuthenticationFailed() {
        lock.lock(); defer { lock.unlock() }
        authenticationFailedCalls += 1
    }
}

extension NetworkSuite {

    private func refreshConfig() -> SdkConfig {
        SdkConfig(
            environment: .staging,
            clientName: "acme",
            clientId: "the-client",
            clientSecret: "the-secret"
        )
    }

    private struct Payload: Decodable {
        let count: Int
    }

    private var payloadJson: String { #"{"count":42,"results":[]}"# }

    private func nearExpiryState(accessToken: String = "stale-access", refreshToken: String = "refresh-0") -> AuthState {
        .authenticated(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresAt: Date().addingTimeInterval(60)
        )
    }

    private func validityWindowState(accessToken: String = "revoked-access", refreshToken: String = "refresh-0") -> AuthState {
        .authenticated(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresAt: Date().addingTimeInterval(3600)
        )
    }

    @Test("Network error during refresh preserves the session")
    func refreshNetworkErrorPreservesSession() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = { request in
            guard let url = request.url else { throw URLError(.badURL) }
            if url.path.contains("/auth/token") {
                throw URLError(.timedOut)
            }
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["Content-Type": "application/json"])!
            return (response, self.payloadJson.data(using: .utf8))
        }

        let session = RecordingSessionProvider(initial: nearExpiryState())
        let client = HTTPClient(config: refreshConfig(), sessionProvider: session, session: MockSession.make())

        await #expect(throws: Error.self) {
            let _: Payload = try await client.fetch(endpoint: .countries)
        }
        #expect(session.authenticationFailedCalls == 0)
        #expect(session.getAuthState().isAuthenticated)
    }

    @Test("Server 5xx during refresh preserves the session")
    func refreshServerErrorPreservesSession() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.sequence([
            (statusCode: 401, json: nil),
            (statusCode: 503, json: #"{"error":"unavailable"}"#)
        ])

        let session = RecordingSessionProvider(initial: validityWindowState())
        let client = HTTPClient(config: refreshConfig(), sessionProvider: session, session: MockSession.make())

        await #expect(throws: Error.self) {
            let _: Payload = try await client.fetch(endpoint: .countries)
        }
        #expect(session.authenticationFailedCalls == 0)
        #expect(session.getAuthState().isAuthenticated)
    }

    @Test("Rejected refresh token ends the session")
    func rejectedRefreshTokenEndsSession() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.sequence([
            (statusCode: 401, json: nil),
            (statusCode: 400, json: #"{"error":"invalid_grant","error_description":"consumed"}"#)
        ])

        let session = RecordingSessionProvider(initial: validityWindowState())
        let client = HTTPClient(config: refreshConfig(), sessionProvider: session, session: MockSession.make())

        await #expect(throws: SdkError.self) {
            let _: Payload = try await client.fetch(endpoint: .countries)
        }
        #expect(session.authenticationFailedCalls == 1)
    }

    @Test("Concurrent requests with an expiring token refresh exactly once")
    func concurrentExpiredRequestsRefreshOnce() async throws {
        MockURLProtocol.reset()
        let server = SingleUseTokenServer(refreshToken: "refresh-0", refreshDelay: 0.15)
        MockURLProtocol.handler = server.handler(successJson: payloadJson)

        let session = RecordingSessionProvider(initial: nearExpiryState())
        let client = HTTPClient(config: refreshConfig(), sessionProvider: session, session: MockSession.make())

        let results = await withTaskGroup(of: Int?.self) { group in
            for _ in 0..<5 {
                group.addTask {
                    let payload: Payload? = try? await client.fetch(endpoint: .countries)
                    return payload?.count
                }
            }
            var collected: [Int?] = []
            for await result in group {
                collected.append(result)
            }
            return collected
        }

        #expect(results.compactMap(\.self).count == 5)
        #expect(server.tokenEndpointCalls == 1)
        #expect(session.authenticationFailedCalls == 0)
    }

    @Test("Concurrent 401 retries never replay a consumed refresh token")
    func concurrentRetriesNeverReplayConsumedToken() async throws {
        MockURLProtocol.reset()
        let server = SingleUseTokenServer(refreshToken: "refresh-0", refreshDelay: 0.15)
        MockURLProtocol.handler = server.handler(successJson: payloadJson)

        let session = RecordingSessionProvider(initial: validityWindowState())
        let client = HTTPClient(config: refreshConfig(), sessionProvider: session, session: MockSession.make())

        let results = await withTaskGroup(of: Int?.self) { group in
            for _ in 0..<5 {
                group.addTask {
                    let payload: Payload? = try? await client.fetch(endpoint: .countries)
                    return payload?.count
                }
            }
            var collected: [Int?] = []
            for await result in group {
                collected.append(result)
            }
            return collected
        }

        #expect(results.compactMap(\.self).count == 5)
        #expect(server.tokenEndpointCalls == 1)
        #expect(session.authenticationFailedCalls == 0)
    }

    @Test("Failing token persistence does not end the session")
    func failingTokenPersistencePreservesSession() async throws {
        MockURLProtocol.reset()
        let server = SingleUseTokenServer(refreshToken: "refresh-0")
        MockURLProtocol.handler = server.handler(successJson: payloadJson)

        let session = SaveThrowingSessionProvider(initial: nearExpiryState())
        let client = HTTPClient(config: refreshConfig(), sessionProvider: session, session: MockSession.make())

        await #expect(throws: Error.self) {
            let _: Payload = try await client.fetch(endpoint: .countries)
        }
        #expect(session.authenticationFailedCalls == 0)
    }
}
