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

    func fetchKredsBalance(forceRefresh: Bool = true, cacheTTL: TimeInterval = 3600) async throws -> KredsLoyaltyBalanceResponse {
        let cacheKey = "kreds_balance"
        if !forceRefresh, let cached: KredsLoyaltyBalanceResponse = await cache.get(cacheKey) {
            return cached
        }
        do {
            let response: KredsLoyaltyBalanceResponse = try await client.fetch(
                endpoint: .loyaltyPoints,
                method: .GET
            )
            await cache.set(cacheKey, value: response, ttl: cacheTTL)
            return response
        } catch {
            if let expired: KredsLoyaltyBalanceResponse = await cache.getExpired(cacheKey) {
                return expired
            }
            throw error
        }
    }
}
