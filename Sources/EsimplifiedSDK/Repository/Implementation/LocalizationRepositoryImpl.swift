//
//  LocalizationRepositoryImpl.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/11/18.
//

import Foundation

final class LocalizationRepositoryImpl: LocalizationRepositoryType {

    private let client: HTTPClient
    private let cache: SdkCache

    private static let cachePrefix = "localization_"
    private static let requestTimeout: TimeInterval = 10

    init(client: HTTPClient, cache: SdkCache) {
        self.client = client
        self.cache = cache
    }

    // MARK: Localization

    func fetchLocalizationResult(
        include: LocalizationInclude?,
        forceRefresh: Bool = false,
        cacheTTL: TimeInterval = 3600
    ) async -> RepositoryResult<Localization> {
        let cacheKey = "\(Self.cachePrefix)\(include?.rawValue ?? "all")"
        if !forceRefresh, let cached: Localization = await cache.get(cacheKey) {
            return RepositoryResult(value: cached)
        }
        do {
            let response: Localization = try await client.fetch(
                endpoint: .localization,
                method: .GET,
                parameters: include.map { ["include": $0.rawValue] },
                requiresAuth: false,
                timeout: Self.requestTimeout
            )
            await cache.set(cacheKey, value: response, ttl: cacheTTL)
            return RepositoryResult(value: response)
        } catch {
            let failure = error as? SdkError ?? .unknown(error)
            let expired: Localization? = await cache.getExpired(cacheKey)
            return RepositoryResult(value: expired ?? Localization(), isStale: expired != nil, failure: failure)
        }
    }

    func fetchLocalization(
        include: LocalizationInclude?,
        forceRefresh: Bool = false,
        cacheTTL: TimeInterval = 3600
    ) async -> Localization {
        await fetchLocalizationResult(
            include: include,
            forceRefresh: forceRefresh,
            cacheTTL: cacheTTL
        ).value
    }

    // MARK: Cache

    func invalidateCache() async {
        await cache.removeWithPrefix(Self.cachePrefix)
    }
}
