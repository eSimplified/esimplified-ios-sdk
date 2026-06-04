//
//  AuthState.swift
//  EsimplifiedSDK
//
//  Created by Kieran on 2026/06/04.
//

import Foundation

public enum AuthState: Equatable {
    case authenticated(accessToken: String, refreshToken: String, expiresAt: Date)
    case unauthenticated

    public var isAuthenticated: Bool {
        if case .authenticated = self { return true }
        return false
    }

    public var accessToken: String? {
        if case .authenticated(let token, _, _) = self { return token }
        return nil
    }

    public var refreshToken: String? {
        if case .authenticated(_, let token, _) = self { return token }
        return nil
    }

    public var isExpired: Bool {
        guard case .authenticated(_, _, let expiresAt) = self else { return true }
        return Date().addingTimeInterval(300) >= expiresAt
    }
}
