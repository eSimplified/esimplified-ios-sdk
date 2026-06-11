//
//  HTTPClientTests.swift
//  EsimplifiedSDK
//

import Testing
import Foundation
@testable import EsimplifiedSDK

extension NetworkSuite {

    private func makeConfig(
        clientName: String = "acme",
        clientId: String = "the-client",
        clientSecret: String = "the-secret",
        awsWafToken: String = "",
        customHeaders: (() async -> [String: String])? = nil
    ) -> SdkConfig {
        SdkConfig(
            environment: .staging,
            clientName: clientName,
            clientId: clientId,
            clientSecret: clientSecret,
            awsWafToken: awsWafToken,
            customHeadersProvider: customHeaders
        )
    }

    private func authenticatedState(
        accessToken: String = "the-access-token",
        refreshToken: String = "the-refresh-token",
        expiresIn: TimeInterval = 3600
    ) -> AuthState {
        .authenticated(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresAt: Date().addingTimeInterval(expiresIn)
        )
    }

    private struct CountriesPayload: Decodable {
        let count: Int
    }

    private var countriesJson: String { #"{"count":42,"results":[]}"# }

    // MARK: - Bearer / Basic auth selection

    @Test("Authenticated request attaches Bearer token")
    func bearerAttachedOnAuthRequest() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: countriesJson)

        let session = RecordingSessionProvider(initial: authenticatedState())
        let client = HTTPClient(config: makeConfig(), sessionProvider: session, session: MockSession.make())

        _ = try await client.fetch(
            endpoint: .countries,
            method: .GET,
            parameters: nil,
            body: nil,
            id: nil,
            requiresAuth: true
        ) as CountriesPayload

        let captured = MockURLProtocol.capturedRequests
        #expect(captured.count == 1)
        #expect(captured.first?.value(forHTTPHeaderField: "Authorization") == "Bearer the-access-token")
    }

    @Test("/auth/token/ endpoint always uses Basic auth")
    func basicAuthOnAuthEndpoint() async throws {
        MockURLProtocol.reset()
        let json = #"{"access_token":"new","expires_in":3600,"token_type":"Bearer","scope":"all","refresh_token":"r"}"#
        MockURLProtocol.handler = MockSession.jsonResponse(json: json)

        let session = RecordingSessionProvider(initial: authenticatedState())
        let client = HTTPClient(config: makeConfig(), sessionProvider: session, session: MockSession.make())

        _ = try await client.fetch(
            endpoint: .auth,
            method: .POST,
            parameters: nil,
            body: ["grant_type": "refresh_token", "refresh_token": "r"],
            id: nil,
            requiresAuth: false
        ) as SignInCustomerResponse

        let authHeader = MockURLProtocol.capturedRequests.first?.value(forHTTPHeaderField: "Authorization")
        #expect(authHeader != nil)
        #expect(authHeader?.hasPrefix("Basic ") == true)

        let expected = "the-client:the-secret".data(using: .utf8)!.base64EncodedString()
        #expect(authHeader == "Basic \(expected)")
    }

    // MARK: - Custom headers

    @Test("customHeadersProvider headers attached to requests")
    func customHeadersAttached() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: countriesJson)

        let config = makeConfig(customHeaders: {
            ["accept-currency": "USD", "accept-language": "en"]
        })
        let session = RecordingSessionProvider(initial: authenticatedState())
        let client = HTTPClient(config: config, sessionProvider: session, session: MockSession.make())

        _ = try await client.fetch(endpoint: .countries) as CountriesPayload

        let req = MockURLProtocol.capturedRequests.first
        #expect(req?.value(forHTTPHeaderField: "accept-currency") == "USD")
        #expect(req?.value(forHTTPHeaderField: "accept-language") == "en")
    }

    @Test("x-auth-validation header attached when awsWafToken non-empty")
    func wafHeaderAttached() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: countriesJson)

        let config = makeConfig(awsWafToken: "waf-token-123")
        let session = RecordingSessionProvider(initial: authenticatedState())
        let client = HTTPClient(config: config, sessionProvider: session, session: MockSession.make())

        _ = try await client.fetch(endpoint: .countries) as CountriesPayload

        let req = MockURLProtocol.capturedRequests.first
        #expect(req?.value(forHTTPHeaderField: "x-auth-validation") == "waf-token-123")
    }

    @Test("x-auth-validation header omitted when awsWafToken empty")
    func wafHeaderOmitted() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: countriesJson)

        let session = RecordingSessionProvider(initial: authenticatedState())
        let client = HTTPClient(config: makeConfig(), sessionProvider: session, session: MockSession.make())

        _ = try await client.fetch(endpoint: .countries) as CountriesPayload

        let req = MockURLProtocol.capturedRequests.first
        #expect(req?.value(forHTTPHeaderField: "x-auth-validation") == nil)
    }

    // MARK: - Body encoding

    @Test("Auth body uses restrictive percent-encoding for @ & = +")
    func authBodyRestrictiveEncoding() async throws {
        MockURLProtocol.reset()
        let json = #"{"access_token":"x","expires_in":3600,"token_type":"Bearer","scope":"all","refresh_token":"r"}"#
        MockURLProtocol.handler = MockSession.jsonResponse(json: json)

        let session = RecordingSessionProvider()
        let client = HTTPClient(config: makeConfig(), sessionProvider: session, session: MockSession.make())

        _ = try await client.fetch(
            endpoint: .auth,
            method: .POST,
            parameters: nil,
            body: ["username": "foo+bar@example.com", "password": "p@ss=w&rd", "grant_type": "password"],
            id: nil,
            requiresAuth: false
        ) as SignInCustomerResponse

        let body = MockURLProtocol.capturedBodies.first ?? nil
        let bodyString = body.flatMap { String(data: $0, encoding: .utf8) } ?? ""

        #expect(bodyString.contains("foo%2Bbar%40example.com"))
        #expect(bodyString.contains("p%40ss%3Dw%26rd"))
    }

    @Test("Auth endpoint uses form Content-Type")
    func authEndpointFormContentType() async throws {
        MockURLProtocol.reset()
        let json = #"{"access_token":"x","expires_in":3600,"token_type":"Bearer","scope":"all","refresh_token":"r"}"#
        MockURLProtocol.handler = MockSession.jsonResponse(json: json)

        let session = RecordingSessionProvider()
        let client = HTTPClient(config: makeConfig(), sessionProvider: session, session: MockSession.make())

        _ = try await client.fetch(
            endpoint: .auth,
            method: .POST,
            parameters: nil,
            body: ["grant_type": "password"],
            id: nil,
            requiresAuth: false
        ) as SignInCustomerResponse

        let contentType = MockURLProtocol.capturedRequests.first?.value(forHTTPHeaderField: "Content-Type")
        #expect(contentType == "application/x-www-form-urlencoded")
    }

    @Test("Non-auth POST uses JSON Content-Type")
    func nonAuthPostJsonContentType() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: #"{"deleted":true}"#)

        let session = RecordingSessionProvider(initial: authenticatedState())
        let client = HTTPClient(config: makeConfig(), sessionProvider: session, session: MockSession.make())

        struct Body: Encodable { let foo: String }
        struct Resp: Decodable { let deleted: Bool }
        _ = try await client.fetch(
            endpoint: .deleteAccount,
            method: .POST,
            parameters: nil,
            body: Body(foo: "bar"),
            id: nil,
            requiresAuth: true
        ) as Resp

        let contentType = MockURLProtocol.capturedRequests.first?.value(forHTTPHeaderField: "Content-Type")
        #expect(contentType == "application/json; charset=utf-8")
    }

    // MARK: - 401 / 403 refresh and retry

    @Test("401 response triggers refresh and retries original request")
    func refreshAndRetryOn401() async throws {
        MockURLProtocol.reset()
        let refreshJson = #"{"access_token":"new-access","expires_in":3600,"token_type":"Bearer","scope":"all","refresh_token":"new-refresh"}"#
        MockURLProtocol.handler = MockSession.sequence([
            (statusCode: 401, json: nil),
            (statusCode: 200, json: refreshJson),
            (statusCode: 200, json: countriesJson)
        ])

        let session = RecordingSessionProvider(initial: authenticatedState(accessToken: "old", refreshToken: "old-r"))
        let client = HTTPClient(config: makeConfig(), sessionProvider: session, session: MockSession.make())

        let result: CountriesPayload = try await client.fetch(endpoint: .countries)
        #expect(result.count == 42)

        let captured = MockURLProtocol.capturedRequests
        #expect(captured.count == 3)
        #expect(captured[0].value(forHTTPHeaderField: "Authorization") == "Bearer old")
        #expect(captured[1].url?.path.contains("/auth/token") == true)
        #expect(captured[2].value(forHTTPHeaderField: "Authorization") == "Bearer new-access")
        #expect(session.tokenRefreshedCalls.count == 1)
    }

    @Test("403 response also triggers refresh and retry")
    func refreshAndRetryOn403() async throws {
        MockURLProtocol.reset()
        let refreshJson = #"{"access_token":"new","expires_in":3600,"token_type":"Bearer","scope":"all","refresh_token":"new-r"}"#
        MockURLProtocol.handler = MockSession.sequence([
            (statusCode: 403, json: nil),
            (statusCode: 200, json: refreshJson),
            (statusCode: 200, json: countriesJson)
        ])

        let session = RecordingSessionProvider(initial: authenticatedState(accessToken: "old"))
        let client = HTTPClient(config: makeConfig(), sessionProvider: session, session: MockSession.make())

        let result: CountriesPayload = try await client.fetch(endpoint: .countries)
        #expect(result.count == 42)
        #expect(MockURLProtocol.capturedRequests.count == 3)
    }

    @Test("Failed refresh emits onAuthenticationFailed and throws authenticationRequired")
    func failedRefreshThrowsAuthenticationRequired() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.sequence([
            (statusCode: 401, json: nil),
            (statusCode: 401, json: #"{"error":"invalid_grant","error_description":"refresh expired"}"#)
        ])

        let session = RecordingSessionProvider(initial: authenticatedState(accessToken: "old"))
        let client = HTTPClient(config: makeConfig(), sessionProvider: session, session: MockSession.make())

        await #expect(throws: SdkError.self) {
            let _: CountriesPayload = try await client.fetch(endpoint: .countries)
        }
        #expect(session.authenticationFailedCalls == 1)
    }

    @Test("Missing refresh token throws authenticationRequired without network call")
    func noRefreshTokenThrows() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.emptyResponse(statusCode: 401)

        let session = RecordingSessionProvider(initial: .unauthenticated)
        let client = HTTPClient(config: makeConfig(), sessionProvider: session, session: MockSession.make())

        await #expect(throws: SdkError.self) {
            let _: CountriesPayload = try await client.fetch(endpoint: .countries)
        }
        #expect(session.authenticationFailedCalls == 1)
    }

    // MARK: - Proactive refresh

    @Test("Proactive refresh fires when token expires within 5-minute buffer")
    func proactiveRefreshOnExpiringToken() async throws {
        MockURLProtocol.reset()
        let refreshJson = #"{"access_token":"fresh","expires_in":3600,"token_type":"Bearer","scope":"all","refresh_token":"new-r"}"#
        MockURLProtocol.handler = MockSession.sequence([
            (statusCode: 200, json: refreshJson),
            (statusCode: 200, json: countriesJson)
        ])

        let nearExpiry: AuthState = .authenticated(
            accessToken: "stale",
            refreshToken: "old-r",
            expiresAt: Date().addingTimeInterval(60)
        )
        let session = RecordingSessionProvider(initial: nearExpiry)
        let client = HTTPClient(config: makeConfig(), sessionProvider: session, session: MockSession.make())

        let result: CountriesPayload = try await client.fetch(endpoint: .countries)
        #expect(result.count == 42)

        let captured = MockURLProtocol.capturedRequests
        #expect(captured.count == 2)
        #expect(captured[0].url?.path.contains("/auth/token") == true)
        #expect(captured[1].value(forHTTPHeaderField: "Authorization") == "Bearer fresh")
    }

    // MARK: - Error response parsing

    @Test("ApiErrorResponse parsed on non-auth endpoints")
    func apiErrorParsingNonAuth() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(
            statusCode: 422,
            json: #"{"error":"validation_error","detail":"Email is required"}"#
        )

        let session = RecordingSessionProvider(initial: authenticatedState())
        let client = HTTPClient(config: makeConfig(), sessionProvider: session, session: MockSession.make())

        do {
            let _: CountriesPayload = try await client.fetch(endpoint: .countries)
            Issue.record("Expected throw")
        } catch let SdkError.networkError(statusCode, message) {
            #expect(statusCode == 422)
            #expect(message == "Email is required")
        }
    }

    @Test("ServerErrorResponse parsed on /auth/token/ errors")
    func serverErrorParsingAuth() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(
            statusCode: 400,
            json: #"{"error":"invalid_grant","error_description":"Bad password"}"#
        )

        let session = RecordingSessionProvider()
        let client = HTTPClient(config: makeConfig(), sessionProvider: session, session: MockSession.make())

        do {
            let _: SignInCustomerResponse = try await client.fetch(
                endpoint: .auth,
                method: .POST,
                parameters: nil,
                body: ["grant_type": "password"],
                id: nil,
                requiresAuth: false
            )
            Issue.record("Expected throw")
        } catch let SdkError.networkError(statusCode, message) {
            #expect(statusCode == 400)
            #expect(message == "Bad password")
        }
    }

    @Test("Decoding failure yields SdkError.decodingError")
    func decodingErrorOnGarbledResponse() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: "not-json-at-all")

        let session = RecordingSessionProvider(initial: authenticatedState())
        let client = HTTPClient(config: makeConfig(), sessionProvider: session, session: MockSession.make())

        do {
            let _: CountriesPayload = try await client.fetch(endpoint: .countries)
            Issue.record("Expected throw")
        } catch SdkError.decodingError {
            // expected
        } catch {
            Issue.record("Wrong error: \(error)")
        }
    }

    // MARK: - URL construction

    @Test("URL construction substitutes id into placeholder")
    func urlWithPlaceholderSubstitution() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: #"{"message":"ok"}"#)

        let session = RecordingSessionProvider(initial: authenticatedState())
        let client = HTTPClient(config: makeConfig(), sessionProvider: session, session: MockSession.make())

        struct Ack: Decodable { let message: String }
        _ = try await client.fetch(
            endpoint: .updateEsim,
            method: .PUT,
            parameters: nil,
            body: nil,
            id: "ABC123",
            requiresAuth: true
        ) as Ack

        let url = MockURLProtocol.capturedRequests.first?.url
        #expect(url?.path.contains("/customer/esims/ABC123") == true)
        #expect(url?.path.contains("placeholder") == false)
    }

    @Test("URL construction appends id without placeholder and adds trailing slash")
    func urlWithIdAppend() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: countriesJson)

        let session = RecordingSessionProvider(initial: authenticatedState())
        let client = HTTPClient(config: makeConfig(), sessionProvider: session, session: MockSession.make())

        _ = try await client.fetch(
            endpoint: .customerOrders,
            method: .GET,
            parameters: nil,
            body: nil,
            id: "order-uuid-9",
            requiresAuth: true
        ) as CountriesPayload

        let url = MockURLProtocol.capturedRequests.first?.url
        #expect(url?.path.hasSuffix("/customer/orders/order-uuid-9") == true)
    }

    @Test("URL construction serializes query parameters")
    func urlWithQueryParams() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: countriesJson)

        let session = RecordingSessionProvider()
        let client = HTTPClient(config: makeConfig(), sessionProvider: session, session: MockSession.make())

        _ = try await client.fetch(
            endpoint: .countries,
            method: .GET,
            parameters: ["limit": "1000", "search": "Canada"],
            body: nil,
            id: nil,
            requiresAuth: false
        ) as CountriesPayload

        let url = MockURLProtocol.capturedRequests.first?.url
        let queryItems = url.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false)?.queryItems } ?? []
        #expect(queryItems.contains(where: { $0.name == "limit" && $0.value == "1000" }))
        #expect(queryItems.contains(where: { $0.name == "search" && $0.value == "Canada" }))
    }

    @Test("Base URL uses clientName and staging path")
    func stagingBaseURL() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: countriesJson)

        let session = RecordingSessionProvider(initial: authenticatedState())
        let client = HTTPClient(config: makeConfig(clientName: "knowroaming"), sessionProvider: session, session: MockSession.make())

        _ = try await client.fetch(endpoint: .countries) as CountriesPayload

        let url = MockURLProtocol.capturedRequests.first?.url
        #expect(url?.host == "knowroaming.stage.esimplified.io")
    }
}
