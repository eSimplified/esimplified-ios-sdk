//
//  PromoCodeRepositoryImpl.swift
//  EsimplifiedSDK
//

import Foundation

final class PromoCodeRepositoryImpl: PromoCodeRepositoryType {

    private let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }

    func fetchPromocode() async throws -> PromoCodeResponse {
        try await client.fetch(
            endpoint: .promoCode,
            method: .GET
        )
    }

    func applyPromocode(code: String) async throws -> PromoCodeResponse {
        try await client.fetch(
            endpoint: .promoCode,
            method: .POST,
            body: ["promo_code": code]
        )
    }

    func deletePromocode(code: String) async throws -> PromoCodeResponse {
        try await client.fetch(
            endpoint: .promoCode,
            method: .DELETE
        )
    }
}
