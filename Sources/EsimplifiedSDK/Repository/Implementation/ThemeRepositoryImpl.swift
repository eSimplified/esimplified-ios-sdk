//
//  ThemeRepositoryImpl.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/09/07.
//

import Foundation

final class ThemeRepositoryImpl: ThemeRepositoryType {

    private let client: HTTPClient
    private let cache: SdkCache
    private static let cacheKeyPrefix = "theme_"

    init(client: HTTPClient, cache: SdkCache) {
        self.client = client
        self.cache = cache
    }

    func fetchPageTheme(page: String, forceRefresh: Bool, cacheTTL: TimeInterval) async throws -> ThemePage? {
        let cacheKey = Self.cacheKeyPrefix + "page_" + page
        if !forceRefresh, let cached: ThemePage = await cache.get(cacheKey) {
            return cached
        }
        do {
            let response: ThemeResponse = try await client.fetch(
                endpoint: .theme,
                method: .GET,
                parameters: ["url": "/" + page],
                requiresAuth: false
            )
            let theme = response.pages[page]
            if let theme {
                await cache.set(cacheKey, value: theme, ttl: cacheTTL)
            }
            return theme
        } catch {
            if let expired: ThemePage = await cache.getExpired(cacheKey) {
                return expired
            }
            throw error
        }
    }

    func fetchDestinationTheme(countryCode: String, forceRefresh: Bool, cacheTTL: TimeInterval) async throws -> ThemeDestination? {
        let code = countryCode.lowercased()
        let cacheKey = Self.cacheKeyPrefix + "destination_" + code
        if !forceRefresh, let cached: ThemeDestination = await cache.get(cacheKey) {
            return cached
        }
        do {
            let response: ThemeResponse = try await client.fetch(
                endpoint: .theme,
                method: .GET,
                parameters: ["url": "/destinations/" + code],
                requiresAuth: false
            )
            let theme = response.destinations.values.first { $0.countryCode?.lowercased() == code }
            if let theme {
                await cache.set(cacheKey, value: theme, ttl: cacheTTL)
            }
            return theme
        } catch {
            if let expired: ThemeDestination = await cache.getExpired(cacheKey) {
                return expired
            }
            throw error
        }
    }

    func invalidateCache() async {
        await cache.removeWithPrefix(Self.cacheKeyPrefix)
    }
}
