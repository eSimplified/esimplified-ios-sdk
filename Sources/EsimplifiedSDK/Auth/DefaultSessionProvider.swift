//
//  DefaultSessionProvider.swift
//  EsimplifiedSDK
//
//  Created by Kieran on 2026/06/04.
//

import Foundation

final class DefaultSessionProvider: SessionProvider {

    private let storage: StorageProvider
    private var cachedState: AuthState = .unauthenticated

    private enum Keys {
        static let accessToken = "sdk_access_token"
        static let refreshToken = "sdk_refresh_token"
        static let expiresAt = "sdk_token_expires_at"
    }

    init(storage: StorageProvider) {
        self.storage = storage
        self.cachedState = loadFromStorage()
    }

    func saveAuthState(_ state: AuthState) throws {
        cachedState = state
        switch state {
        case .authenticated(let accessToken, let refreshToken, let expiresAt):
            try storage.save(accessToken, forKey: Keys.accessToken)
            try storage.save(refreshToken, forKey: Keys.refreshToken)
            try storage.save(String(expiresAt.timeIntervalSince1970), forKey: Keys.expiresAt)
        case .unauthenticated:
            try clearSession()
        }
    }

    func getAuthState() -> AuthState {
        cachedState
    }

    func getAccessToken() -> String? {
        cachedState.accessToken
    }

    func getRefreshToken() -> String? {
        cachedState.refreshToken
    }

    func clearSession() throws {
        cachedState = .unauthenticated
        try? storage.delete(forKey: Keys.accessToken)
        try? storage.delete(forKey: Keys.refreshToken)
        try? storage.delete(forKey: Keys.expiresAt)
    }

    private func loadFromStorage() -> AuthState {
        guard let accessToken = storage.retrieve(forKey: Keys.accessToken),
              let refreshToken = storage.retrieve(forKey: Keys.refreshToken),
              let expiresAtString = storage.retrieve(forKey: Keys.expiresAt),
              let expiresAtInterval = Double(expiresAtString) else {
            return .unauthenticated
        }
        let expiresAt = Date(timeIntervalSince1970: expiresAtInterval)
        return .authenticated(accessToken: accessToken, refreshToken: refreshToken, expiresAt: expiresAt)
    }
}
