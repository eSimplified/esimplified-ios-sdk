import Testing
import Foundation
@testable import EsimplifiedSDK

@Suite("DefaultSessionProvider")
struct DefaultSessionProviderTests {

    @Test("Initial state is unauthenticated")
    func initialState() {
        let storage = MockStorageProvider()
        let provider = DefaultSessionProvider(storage: storage)
        #expect(!provider.getAuthState().isAuthenticated)
        #expect(provider.getAccessToken() == nil)
        #expect(provider.getRefreshToken() == nil)
    }

    @Test("Save and retrieve auth state")
    func saveAndRetrieve() throws {
        let storage = MockStorageProvider()
        let provider = DefaultSessionProvider(storage: storage)
        let state = AuthState.authenticated(
            accessToken: "access123",
            refreshToken: "refresh456",
            expiresAt: Date().addingTimeInterval(3600)
        )
        try provider.saveAuthState(state)
        #expect(provider.getAccessToken() == "access123")
        #expect(provider.getRefreshToken() == "refresh456")
        #expect(provider.getAuthState().isAuthenticated)
    }

    @Test("Clear session resets to unauthenticated")
    func clearSession() throws {
        let storage = MockStorageProvider()
        let provider = DefaultSessionProvider(storage: storage)
        try provider.saveAuthState(.authenticated(
            accessToken: "a", refreshToken: "r", expiresAt: Date().addingTimeInterval(3600)
        ))
        try provider.clearSession()
        #expect(!provider.getAuthState().isAuthenticated)
        #expect(provider.getAccessToken() == nil)
    }

    @Test("Save unauthenticated clears session")
    func saveUnauthenticated() throws {
        let storage = MockStorageProvider()
        let provider = DefaultSessionProvider(storage: storage)
        try provider.saveAuthState(.authenticated(
            accessToken: "a", refreshToken: "r", expiresAt: Date().addingTimeInterval(3600)
        ))
        try provider.saveAuthState(.unauthenticated)
        #expect(!provider.getAuthState().isAuthenticated)
    }

    @Test("Persists to storage provider")
    func persistsToStorage() throws {
        let storage = MockStorageProvider()
        let provider = DefaultSessionProvider(storage: storage)
        try provider.saveAuthState(.authenticated(
            accessToken: "tok", refreshToken: "ref", expiresAt: Date().addingTimeInterval(3600)
        ))
        #expect(storage.store["sdk_access_token"] == "tok")
        #expect(storage.store["sdk_refresh_token"] == "ref")
        #expect(storage.store["sdk_token_expires_at"] != nil)
    }
}
