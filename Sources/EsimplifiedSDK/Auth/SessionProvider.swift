import Foundation

public protocol SessionProvider {
    func saveAuthState(_ state: AuthState) throws
    func getAuthState() -> AuthState
    func getAccessToken() -> String?
    func getRefreshToken() -> String?
    func clearSession() throws
    func getUserEmail() -> String?
    func onTokenRefreshed(response: SignInCustomerResponse)
    func onAuthenticationFailed()
}

public extension SessionProvider {
    func getUserEmail() -> String? { nil }
    func onTokenRefreshed(response: SignInCustomerResponse) {}
    func onAuthenticationFailed() {}
}
