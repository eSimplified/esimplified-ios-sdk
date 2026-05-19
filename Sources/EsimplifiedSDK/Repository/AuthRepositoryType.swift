//
//  AuthRepositoryType.swift
//  EsimplifiedSDK
//

import Foundation

public protocol AuthRepositoryType {
    func login(email: String, password: String) async throws -> SignInCustomerResponse
    func loginWithProvider(
        firstName: String,
        lastName: String,
        fullName: String,
        email: String,
        provider: String,
        providerAccountId: String,
        idToken: String
    ) async throws -> SignInCustomerResponse
    func register(request: RegisterCustomerRequest) async throws -> RegisterCustomerResponse
    func forgotPassword(email: String) async throws -> ForgotPasswordResponse
    func resetPassword(email: String, token: String, newPassword: String) async throws -> ChangePasswordResponse
    func changePassword(email: String, currentPassword: String, newPassword: String) async throws -> ChangePasswordResponse
    func verifyEmail(email: String?, token: String?, orderUUID: String?) async throws -> VerifyEmailResponse
    func deleteAccount() async throws -> DeleteAccountResponse
    func logout() throws
}
