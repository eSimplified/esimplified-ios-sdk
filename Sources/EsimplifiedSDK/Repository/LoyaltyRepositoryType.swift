//
//  LoyaltyRepositoryType.swift
//  EsimplifiedSDK
//

import Foundation

public protocol LoyaltyRepositoryType {
    func fetchKredsBalance(forceRefresh: Bool) async throws -> KredsLoyaltyBalanceResponse
}

public extension LoyaltyRepositoryType {
    func fetchKredsBalance() async throws -> KredsLoyaltyBalanceResponse {
        try await fetchKredsBalance(forceRefresh: false)
    }
}
