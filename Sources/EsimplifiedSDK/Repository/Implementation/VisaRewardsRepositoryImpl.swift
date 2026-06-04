//
//  VisaRewardsRepositoryImpl.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/06/04.
//

import Foundation

final class VisaRewardsRepositoryImpl: VisaRewardsRepositoryType {

    private let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }

    func fetchVisaReward(isEU: Bool) async -> VisaRewardResponse? {
        let body: [String: String]? = isEU ? ["vendor": "eu"] : nil
        do {
            return try await client.fetch(
                endpoint: .visaIframe,
                method: .POST,
                body: body
            )
        } catch {
            return nil
        }
    }

    func fetchVisaValidation(token: String) async -> VisaValidateResponse? {
        do {
            return try await client.fetch(
                endpoint: .validateVisa,
                method: .GET,
                id: token
            )
        } catch {
            return nil
        }
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
