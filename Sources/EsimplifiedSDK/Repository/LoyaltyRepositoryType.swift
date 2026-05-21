//
//  LoyaltyRepositoryType.swift
//  EsimplifiedSDK
//

import Foundation

public protocol LoyaltyRepositoryType {
    func fetchKredsBalance(forceRefresh: Bool = true) async throws -> KredsLoyaltyBalanceResponse
}
