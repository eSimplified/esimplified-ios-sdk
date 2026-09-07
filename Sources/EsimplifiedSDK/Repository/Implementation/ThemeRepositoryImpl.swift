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

    func fetchTheme(page: String, forceRefresh: Bool, cacheTTL: TimeInterval) async throws -> PageTheme {
        let cacheKey = Self.cacheKeyPrefix + page
        if !forceRefresh, let cached: PageTheme = await cache.get(cacheKey) {
            return cached
        }
        do {
            let theme: PageTheme = try await client.fetch(
                endpoint: .theme,
                method: .GET,
                parameters: ["page": page],
                requiresAuth: false
            )
            await cache.set(cacheKey, value: theme, ttl: cacheTTL)
            return theme
        } catch {
            if let expired: PageTheme = await cache.getExpired(cacheKey) {
                return expired
            }
            throw error
        }
    }

    func invalidateCache() async {
        await cache.removeWithPrefix(Self.cacheKeyPrefix)
    }
}
