//
//  AuthFlowTests.swift
//  EsimplifiedSDK
//

import Testing
import Foundation
@testable import EsimplifiedSDK

extension NetworkSuite {

    private func makeRepo(initial: AuthState = .unauthenticated) -> (AuthRepositoryImpl, RecordingSessionProvider) {
        let config = SdkConfig(
            environment: .staging,
            clientName: "acme",
            clientId: "id",
            clientSecret: "secret"
        )
        let session = RecordingSessionProvider(initial: initial)
        let client = HTTPClient(config: config, sessionProvider: session, session: MockSession.make())
        let repo = AuthRepositoryImpl(client: client, sessionProvider: session, config: config)
        return (repo, session)
    }

    private var validLoginResponse: String { #"{"access_token":"new-access","expires_in":3600,"token_type":"Bearer","scope":"all","refresh_token":"new-refresh"}"# }

    @Test("login persists tokens via SessionProvider")
    func loginPersistsTokens() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: validLoginResponse)

        let (repo, session) = makeRepo()
        let response = try await repo.login(email: "u@example.com", password: "p")

        #expect(response.accessToken == "new-access")
        #expect(session.saveAuthStateCalls.count == 1)
        #expect(session.getAccessToken() == "new-access")
        #expect(session.getRefreshToken() == "new-refresh")
    }

    @Test("login throws on bad credentials")
    func loginBadCredentials() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(
            statusCode: 400,
            json: #"{"error":"invalid_grant","error_description":"Bad credentials"}"#
        )

        let (repo, session) = makeRepo()

        do {
            _ = try await repo.login(email: "u@example.com", password: "wrong")
            Issue.record("Expected throw")
        } catch let SdkError.networkError(statusCode, message) {
            #expect(statusCode == 400)
            #expect(message == "Bad credentials")
        }
        #expect(session.saveAuthStateCalls.isEmpty)
    }

    @Test("loginWithProvider persists tokens")
    func loginWithProviderPersists() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: validLoginResponse)

        let (repo, session) = makeRepo()
        _ = try await repo.loginWithProvider(
            firstName: "Alice",
            lastName: "Smith",
            fullName: "Alice Smith",
            email: "alice@example.com",
            provider: .google,
            providerAccountId: "g-123",
            idToken: "id-token"
        )

        #expect(session.getAccessToken() == "new-access")
    }

    @Test("refreshSession emits onTokenRefreshed callback")
    func refreshSessionEmitsCallback() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: validLoginResponse)

        let initial: AuthState = .authenticated(
            accessToken: "old",
            refreshToken: "old-r",
            expiresAt: Date().addingTimeInterval(3600)
        )
        let (repo, session) = makeRepo(initial: initial)

        _ = try await repo.refreshSession()

        #expect(session.tokenRefreshedCalls.count == 1)
        #expect(session.tokenRefreshedCalls.first?.accessToken == "new-access")
        #expect(session.getAccessToken() == "new-access")
    }

    @Test("refreshSession throws authenticationRequired when no refresh token")
    func refreshWithoutToken() async throws {
        MockURLProtocol.reset()

        let (repo, _) = makeRepo()
        await #expect(throws: SdkError.self) {
            _ = try await repo.refreshSession()
        }
    }

    @Test("logout clears session")
    func logoutClearsSession() async throws {
        MockURLProtocol.reset()

        let initial: AuthState = .authenticated(
            accessToken: "a", refreshToken: "r", expiresAt: Date().addingTimeInterval(3600)
        )
        let (repo, session) = makeRepo(initial: initial)

        try repo.logout()

        #expect(session.clearSessionCalls == 1)
        #expect(!session.getAuthState().isAuthenticated)
    }

    @Test("deleteAccount clears session on success")
    func deleteAccountClearsOnSuccess() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: #"{"deleted":true}"#)

        let initial: AuthState = .authenticated(
            accessToken: "a", refreshToken: "r", expiresAt: Date().addingTimeInterval(3600)
        )
        let (repo, session) = makeRepo(initial: initial)

        let response = try await repo.deleteAccount()
        #expect(response.deleted == true)
        #expect(session.clearSessionCalls == 1)
    }

    @Test("deleteAccount preserves session when API reports not-deleted")
    func deleteAccountPreservesOnFailure() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: #"{"deleted":false}"#)

        let initial: AuthState = .authenticated(
            accessToken: "a", refreshToken: "r", expiresAt: Date().addingTimeInterval(3600)
        )
        let (repo, session) = makeRepo(initial: initial)

        _ = try await repo.deleteAccount()
        #expect(session.clearSessionCalls == 0)
    }

    @Test("register hits signup endpoint")
    func registerHitsSignup() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(
            json: #"{"message":"ok","success":true,"email":"a@b.com","referral_code":null}"#
        )

        let (repo, _) = makeRepo()
        let request = RegisterCustomerRequest(
            firstName: "A",
            lastName: "B",
            email: "a@b.com",
            mobileNumber: "+1234",
            referredBy: nil,
            password: "secret",
            marketingOptIn: true
        )
        let response = try await repo.register(request: request)
        #expect(response.success == true)

        let url = MockURLProtocol.capturedRequests.first?.url
        #expect(url?.path.contains("/register") == true)
    }

    @Test("forgotPassword hits forgot-password endpoint")
    func forgotPassword() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: #"{"email":"a@b.com","detail":"sent","customer_id":"c1"}"#)

        let (repo, _) = makeRepo()
        let response = try await repo.forgotPassword(email: "a@b.com")
        #expect(response.email == "a@b.com")

        let url = MockURLProtocol.capturedRequests.first?.url
        #expect(url?.path.contains("/forgot-password") == true)
    }

    @Test("verifyEmail hits verify-email endpoint with all fields nil-safe")
    func verifyEmailNilSafe() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: #"{"email":"a@b.com","email_verified":true}"#)

        let (repo, _) = makeRepo()
        let response = try await repo.verifyEmail(email: nil, token: nil, orderUUID: "order-1")
        #expect(response.email_verified == true)
    }
}
