//
//  LoyaltyRepositoryImpl.swift
//  EsimplifiedSDK
//

import Foundation

final class LoyaltyRepositoryImpl: LoyaltyRepositoryType {

    private let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }

    func fetchKredsBalance() async throws -> KredsLoyaltyBalanceResponse {
        try await client.fetch(
            endpoint: .loyaltyPoints,
            method: .GET
        )
    }
}
