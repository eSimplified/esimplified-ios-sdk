//
//  ThemeRepositoryType.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/09/07.
//

import Foundation

public protocol ThemeRepositoryType {
    func fetchPageTheme(page: String, forceRefresh: Bool, cacheTTL: TimeInterval) async throws -> ThemePage?
    func fetchDestinationTheme(countryCode: String, forceRefresh: Bool, cacheTTL: TimeInterval) async throws -> ThemeDestination?
    func invalidateCache() async
}

public extension ThemeRepositoryType {
    func fetchPageTheme(page: String, forceRefresh: Bool = false) async throws -> ThemePage? {
        try await fetchPageTheme(page: page, forceRefresh: forceRefresh, cacheTTL: 3600)
    }

    func fetchDestinationTheme(countryCode: String, forceRefresh: Bool = false) async throws -> ThemeDestination? {
        try await fetchDestinationTheme(countryCode: countryCode, forceRefresh: forceRefresh, cacheTTL: 3600)
    }
}
