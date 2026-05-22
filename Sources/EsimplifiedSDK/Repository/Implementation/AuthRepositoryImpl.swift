//
//  AuthRepositoryImpl.swift
//  EsimplifiedSDK
//

import Foundation

final class AuthRepositoryImpl: AuthRepositoryType {

    private let client: HTTPClient
    private let sessionProvider: SessionProvider
    private let config: SdkConfig

    init(client: HTTPClient, sessionProvider: SessionProvider, config: SdkConfig) {
        self.client = client
        self.sessionProvider = sessionProvider
        self.config = config
    }

    func login(email: String, password: String) async throws -> SignInCustomerResponse {
        let body: [String: String] = [
            "username": email,
            "password": password,
            "grant_type": "password"
        ]
        let response: SignInCustomerResponse = try await client.fetch(
            endpoint: .auth,
            method: .POST,
            body: body,
            requiresAuth: false
        )
        let expiresAt = Date().addingTimeInterval(TimeInterval(response.tokenExpiresIn))
        try sessionProvider.saveAuthState(.authenticated(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken ?? "",
            expiresAt: expiresAt
        ))
        return response
    }

    func loginWithProvider(
        firstName: String,
        lastName: String,
        fullName: String,
        email: String,
        provider: AuthProvider,
        providerAccountId: String,
        idToken: String
    ) async throws -> SignInCustomerResponse {
        let body: [String: String] = [
            "grant_type": "client_credentials",
            "first_name": firstName,
            "last_name": lastName,
            "full_name": fullName,
            "email": email,
            "provider": provider.rawValue,
            "provider_account_id": providerAccountId,
            "id_token": idToken,
            "sender": "ios"
        ]
        let response: SignInCustomerResponse = try await client.fetch(
            endpoint: .auth,
            method: .POST,
            body: body,
            requiresAuth: false
        )
        let expiresAt = Date().addingTimeInterval(TimeInterval(response.tokenExpiresIn))
        try sessionProvider.saveAuthState(.authenticated(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken ?? "",
            expiresAt: expiresAt
        ))
        return response
    }

    func register(request: RegisterCustomerRequest) async throws -> RegisterCustomerResponse {
        try await client.fetch(
            endpoint: .signUpUser,
            method: .POST,
            body: request,
            requiresAuth: false
        )
    }

    func forgotPassword(email: String) async throws -> ForgotPasswordResponse {
        try await client.fetch(
            endpoint: .forgotPassword,
            method: .POST,
            body: ["email": email],
            requiresAuth: false
        )
    }

    func resetPassword(email: String, token: String, newPassword: String) async throws -> ChangePasswordResponse {
        let body = ["email": email, "password_reset_token": token, "new_password": newPassword]
        return try await client.fetch(
            endpoint: .changePassword,
            method: .POST,
            body: body,
            requiresAuth: false
        )
    }

    func changePassword(email: String, currentPassword: String, newPassword: String) async throws -> ChangePasswordResponse {
        let body = ["email": email, "password": currentPassword, "new_password": newPassword]
        return try await client.fetch(
            endpoint: .changePassword,
            method: .POST,
            body: body
        )
    }

    func verifyEmail(email: String?, token: String?, orderUUID: String?) async throws -> VerifyEmailResponse {
        var body: [String: String] = [:]
        if let email { body["email"] = email }
        if let token { body["email_verification_token"] = token }
        if let orderUUID { body["order_uuid"] = orderUUID }
        return try await client.fetch(
            endpoint: .verifyEmail,
            method: .POST,
            body: body,
            requiresAuth: false
        )
    }

    func refreshSession() async throws -> SignInCustomerResponse {
        guard let refreshToken = sessionProvider.getRefreshToken() else {
            throw SdkError.authenticationRequired
        }
        let body: [String: String] = [
            "grant_type": "refresh_token",
            "refresh_token": refreshToken
        ]
        let response: SignInCustomerResponse = try await client.fetch(
            endpoint: .auth,
            method: .POST,
            body: body,
            requiresAuth: false
        )
        let expiresAt = Date().addingTimeInterval(TimeInterval(response.tokenExpiresIn))
        try sessionProvider.saveAuthState(.authenticated(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken ?? refreshToken,
            expiresAt: expiresAt
        ))
        sessionProvider.onTokenRefreshed(response: response)
        return response
    }

    func deleteAccount() async throws -> DeleteAccountResponse {
        let response: DeleteAccountResponse = try await client.fetch(
            endpoint: .deleteAccount,
            method: .DELETE
        )
        if response.deleted {
            try sessionProvider.clearSession()
        }
        return response
    }

    func logout() throws {
        try sessionProvider.clearSession()
    }
}
