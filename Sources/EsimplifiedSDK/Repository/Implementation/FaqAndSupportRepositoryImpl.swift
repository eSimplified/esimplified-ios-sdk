//
//  FaqAndSupportRepositoryImpl.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/09/01.
//

import Foundation

final class FaqAndSupportRepositoryImpl: FaqAndSupportRepositoryType {

    private let client: HTTPClient
    private let cache: SdkCache

    init(client: HTTPClient, cache: SdkCache) {
        self.client = client
        self.cache = cache
    }

    func fetchDestinationFaqsResult(
        countryNameSlug: String,
        forceRefresh: Bool = false,
        cacheTTL: TimeInterval = 86400
    ) async -> RepositoryResult<[Faq]> {
        let cacheKey = "faqs_destination_\(countryNameSlug)"
        if !forceRefresh, let cached: [Faq] = await cache.get(cacheKey) {
            return RepositoryResult(value: cached)
        }
        do {
            let response: DestinationFaqResponse = try await client.fetch(
                endpoint: .destinationFaqs,
                method: .GET,
                id: countryNameSlug,
                requiresAuth: false
            )
            await cache.set(cacheKey, value: response.faqs, ttl: cacheTTL)
            return RepositoryResult(value: response.faqs)
        } catch {
            let failure = error as? SdkError ?? .unknown(error)
            let expired: [Faq] = await cache.getExpired(cacheKey) ?? []
            return RepositoryResult(value: expired, isStale: !expired.isEmpty, failure: failure)
        }
    }

    func fetchDestinationFaqs(
        countryNameSlug: String,
        forceRefresh: Bool = false,
        cacheTTL: TimeInterval = 86400
    ) async -> [Faq] {
        await fetchDestinationFaqsResult(
            countryNameSlug: countryNameSlug,
            forceRefresh: forceRefresh,
            cacheTTL: cacheTTL
        ).value
    }

    func invalidateCache() async {
        await cache.removeWithPrefix("faqs_")
    }
}
