import Foundation

public protocol SessionProvider {
    func saveAuthState(_ state: AuthState) throws
    func getAuthState() -> AuthState
    func getAccessToken() -> String?
    func getRefreshToken() -> String?
    func clearSession() throws
    func onTokenRefreshed(response: SignInCustomerResponse)
    func onAuthenticationFailed()
}

public extension SessionProvider {
    func onTokenRefreshed(response: SignInCustomerResponse) {}
    func onAuthenticationFailed() {}
}
