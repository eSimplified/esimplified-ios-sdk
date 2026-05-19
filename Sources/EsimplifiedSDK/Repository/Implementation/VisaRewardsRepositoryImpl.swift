//
//  VisaRewardsRepositoryImpl.swift
//  EsimplifiedSDK
//

import Foundation

final class VisaRewardsRepositoryImpl: VisaRewardsRepositoryType {

    private let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }

    func fetchVisaReward(isEU: Bool) async throws -> VisaRewardResponse? {
        let body: [String: String]? = isEU ? ["vendor": "eu"] : nil
        return try await client.fetch(
            endpoint: .visaIframe,
            method: .POST,
            body: body
        )
    }

    func fetchVisaValidation(token: String) async throws -> VisaValidateResponse? {
        try await client.fetch(
            endpoint: .validateVisa,
            method: .GET,
            id: token
        )
    }

    func redeemVisaReward(token: String, body: [String: String]) async throws -> RedeemVisaResponse {
        try await client.fetch(
            endpoint: .validateVisa,
            method: .PATCH,
            body: body,
            id: token
        )
    }
}
