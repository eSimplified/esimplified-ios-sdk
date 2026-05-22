//
//  LoyaltyRepositoryType.swift
//  EsimplifiedSDK
//

import Foundation

public protocol LoyaltyRepositoryType {
    func fetchKredsBalance(forceRefresh: Bool, cacheTTL: TimeInterval) async throws -> KredsLoyaltyBalanceResponse
}

public extension LoyaltyRepositoryType {
    func fetchKredsBalance(forceRefresh: Bool = true) async throws -> KredsLoyaltyBalanceResponse {
        try await fetchKredsBalance(forceRefresh: forceRefresh, cacheTTL: 3600)
    }
}
