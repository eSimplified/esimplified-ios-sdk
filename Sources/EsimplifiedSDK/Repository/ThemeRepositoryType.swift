//
//  ThemeRepositoryType.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/09/07.
//

import Foundation

public protocol ThemeRepositoryType {
    func fetchTheme(page: String, forceRefresh: Bool, cacheTTL: TimeInterval) async throws -> PageTheme
    func invalidateCache() async
}

public extension ThemeRepositoryType {
    func fetchTheme(page: String, forceRefresh: Bool = false) async throws -> PageTheme {
        try await fetchTheme(page: page, forceRefresh: forceRefresh, cacheTTL: 3600)
    }
}
