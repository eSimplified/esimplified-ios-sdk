//
//  VisaRewardsRepositoryType.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/06/04.
//

import Foundation

public protocol VisaRewardsRepositoryType {
    func fetchVisaReward(isEU: Bool) async throws -> VisaRewardResponse
    func fetchVisaValidation(token: String) async throws -> VisaValidateResponse
    func redeemVisaReward(token: String, body: [String: String]) async throws -> RedeemVisaResponse
}
