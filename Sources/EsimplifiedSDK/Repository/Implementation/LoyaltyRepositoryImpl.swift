//
//  LoyaltyRepositoryImpl.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/06/04.
//

import Foundation

final class LoyaltyRepositoryImpl: LoyaltyRepositoryType {

    private let client: HTTPClient
    private let cache: SdkCache

    init(client: HTTPClient, cache: SdkCache) {
        self.client = client
        self.cache = cache
    }

    // MARK: Kreds functions

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

    // MARK: Mokafaa functions

    func initiateOtp(purpose: MokafaaOtpPurpose) async throws -> MokafaaOtpInitiateResponse {
        let body = MokafaaOtpInitiateRequest(purpose: purpose)
        return try await client.fetch(
            endpoint: .initiateMokafaaOtp,
            method: .POST,
            body: body
        )
    }

    func validateOtp(sessionId: String, otp: String, points: Int?) async throws -> MokafaaOtpValidateResponse {
        let body = MokafaaOtpValidateRequest(sessionId: sessionId, otp: otp, points: points)
        return try await client.fetch(
            endpoint: .validateMokafaaOtp,
            method: .POST,
            body: body
        )
    }

    func invalidateCache() async {
        await cache.remove("kreds_balance")
    }
}
