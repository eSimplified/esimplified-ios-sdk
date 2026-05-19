//
//  VisaValidateResponse.swift
//  KnowRoaming
//
//  Created by Kieran on 2025/02/17.
//

import Foundation

// MARK: Visa Validate Response

public struct VisaValidateResponse: Codable, Hashable {
    public var eligible: Bool = false
    public var usedCount: Int? = 0
    public var rewardType: RewardType? = .unknown
    public var allowedCount: Int? = 0
    public var remainingCount: Int? = 0
    public var redeemed: Bool? = false
    public var detail: String? = ""
    public var validityDays: Int?
    public var dataGB: Int?

    public init(eligible: Bool = false, usedCount: Int? = 0, rewardType: RewardType? = .unknown, allowedCount: Int? = 0, remainingCount: Int? = 0, redeemed: Bool? = false, detail: String? = "", validityDays: Int? = nil, dataGB: Int? = nil) {
        self.eligible = eligible
        self.usedCount = usedCount
        self.rewardType = rewardType
        self.allowedCount = allowedCount
        self.remainingCount = remainingCount
        self.redeemed = redeemed
        self.detail = detail
        self.validityDays = validityDays
        self.dataGB = dataGB
    }

    public enum RewardType: String, Codable {
        case unknown
        case discount = "DISCOUNT"
        case global = "GLOBAL_ESIM"

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self)
            self = RewardType(rawValue: value) ?? .unknown
        }
    }

    enum CodingKeys: String, CodingKey {
        case eligible, redeemed, detail
        case usedCount = "used_count"
        case rewardType = "reward_type"
        case allowedCount = "allowed_count"
        case remainingCount = "remaining_count"
        case validityDays = "validity_days"
        case dataGB = "data_GB"
    }
}
