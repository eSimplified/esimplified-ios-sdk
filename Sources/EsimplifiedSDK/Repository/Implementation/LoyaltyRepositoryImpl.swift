//
//  LoyaltyRepositoryImpl.swift
//  EsimplifiedSDK
//

import Foundation

final class LoyaltyRepositoryImpl: LoyaltyRepositoryType {

    private let client: HTTPClient
    private let cache: SdkCache

    init(client: HTTPClient, cache: SdkCache) {
        self.client = client
        self.cache = cache
    }

    func fetchKredsBalance(forceRefresh: Bool = false) async throws -> KredsLoyaltyBalanceResponse {
        let cacheKey = "kreds_balance"
        if !forceRefresh, let cached: KredsLoyaltyBalanceResponse = cache.get(cacheKey) {
            return cached
        }
        let response: KredsLoyaltyBalanceResponse = try await client.fetch(
            endpoint: .loyaltyPoints,
            method: .GET
        )
        cache.set(cacheKey, value: response, ttl: 600)
        return response
    }
}
