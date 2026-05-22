//
//  LoyaltyRepositoryType.swift
//  EsimplifiedSDK
//

import Foundation

public protocol LoyaltyRepositoryType {
    func fetchKredsBalance(forceRefresh: Bool, cacheTTL: TimeInterval) async throws -> KredsLoyaltyBalanceResponse
}
