import Foundation

public protocol SessionProvider {
    func saveAuthState(_ state: AuthState) throws
    func getAuthState() -> AuthState
    func getAccessToken() -> String?
    func getRefreshToken() -> String?
    func clearSession() throws
}
