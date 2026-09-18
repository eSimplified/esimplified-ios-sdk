//
//  MarketingRepositoryImpl.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/09/18.
//

import Foundation

final class MarketingRepositoryImpl: MarketingRepositoryType {

    private let client: HTTPClient
    private let cache: SdkCache

    private static let cachePrefix = "marketing_"

    init(client: HTTPClient, cache: SdkCache) {
        self.client = client
        self.cache = cache
    }

    // MARK: Promos

    func fetchPromosResult(
        language: String,
        forceRefresh: Bool = false,
        cacheTTL: TimeInterval = 3600
    ) async -> RepositoryResult<[Promo]> {
        let cacheKey = "\(Self.cachePrefix)\(language)"
        if !forceRefresh, let cached: [Promo] = await cache.get(cacheKey) {
            return RepositoryResult(value: cached)
        }
        do {
            let response: MarketingPromos = try await client.fetch(
                endpoint: .marketing,
                method: .GET,
                requiresAuth: false
            )
            await cache.set(cacheKey, value: response.promos, ttl: cacheTTL)
            return RepositoryResult(value: response.promos)
        } catch {
            let failure = error as? SdkError ?? .unknown(error)
            let expired: [Promo] = await cache.getExpired(cacheKey) ?? []
            return RepositoryResult(value: expired, isStale: !expired.isEmpty, failure: failure)
        }
    }

    func fetchPromos(
        language: String,
        forceRefresh: Bool = false,
        cacheTTL: TimeInterval = 3600
    ) async -> [Promo] {
        await fetchPromosResult(
            language: language,
            forceRefresh: forceRefresh,
            cacheTTL: cacheTTL
        ).value
    }

    // MARK: Cache

    func invalidateCache() async {
        await cache.removeWithPrefix(Self.cachePrefix)
    }
}
