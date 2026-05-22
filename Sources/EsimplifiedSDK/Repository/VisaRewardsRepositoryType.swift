//
//  VisaRewardsRepositoryType.swift
//  EsimplifiedSDK
//

import Foundation

public protocol VisaRewardsRepositoryType {
    func fetchVisaReward(isEU: Bool) async -> VisaRewardResponse?
    func fetchVisaValidation(token: String) async -> VisaValidateResponse?
    func redeemVisaReward(token: String, body: [String: String]) async throws -> RedeemVisaResponse
}
