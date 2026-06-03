//
//  StoreReviewRepositoryImpl.swift
//  EsimplifiedSDK
//

import Foundation

final class StoreReviewRepositoryImpl: StoreReviewRepositoryType {

    private let client: HTTPClient
    private let cache: SdkCache

    init(client: HTTPClient, cache: SdkCache) {
        self.client = client
        self.cache = cache
    }

    func fetchStoreReview(cacheTTL: TimeInterval = 86400) async throws -> StoreReviewResponse {
        let cacheKey = "store_review"
        if let cached: StoreReviewResponse = await cache.get(cacheKey) {
            return cached
        }
        let parameters = ["type": "store_review"]
        let response: StoreReviewResponse = try await client.fetch(
            endpoint: .storeReview,
            method: .GET,
            parameters: parameters,
            requiresAuth: false
        )
        await cache.set(cacheKey, value: response, ttl: cacheTTL)
        return response
    }

    func invalidateCache() async {
        await cache.remove("store_review")
    }
}
