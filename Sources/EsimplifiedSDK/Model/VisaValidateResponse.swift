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
    public var rewardTypeValue: String?
    public var allowedCount: Int? = 0
    public var remainingCount: Int? = 0
    public var redeemed: Bool? = false
    public var detail: String? = ""
    public var validityDays: Int?
    public var dataGB: Int?

    public init(eligible: Bool = false, usedCount: Int? = 0, rewardType: RewardType? = .unknown, allowedCount: Int? = 0, remainingCount: Int? = 0, redeemed: Bool? = false, detail: String? = "", validityDays: Int? = nil, dataGB: Int? = nil, rewardTypeValue: String? = nil) {
        self.eligible = eligible
        self.usedCount = usedCount
        self.rewardType = rewardType
        self.rewardTypeValue = rewardTypeValue ?? rewardType.flatMap { $0 == .unknown ? nil : $0.rawValue }
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
            self = RewardType(rawValue: value.uppercased()) ?? .unknown
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

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        eligible = try container.decode(Bool.self, forKey: .eligible)
        usedCount = try container.decodeIfPresent(Int.self, forKey: .usedCount)
        rewardType = try container.decodeIfPresent(RewardType.self, forKey: .rewardType)
        rewardTypeValue = try container.decodeIfPresent(String.self, forKey: .rewardType)
        allowedCount = try container.decodeIfPresent(Int.self, forKey: .allowedCount)
        remainingCount = try container.decodeIfPresent(Int.self, forKey: .remainingCount)
        redeemed = try container.decodeIfPresent(Bool.self, forKey: .redeemed)
        detail = try container.decodeIfPresent(String.self, forKey: .detail)
        validityDays = try container.decodeIfPresent(Int.self, forKey: .validityDays)
        dataGB = try container.decodeIfPresent(Int.self, forKey: .dataGB)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(eligible, forKey: .eligible)
        try container.encodeIfPresent(usedCount, forKey: .usedCount)
        try container.encodeIfPresent(rewardTypeValue ?? rewardType?.rawValue, forKey: .rewardType)
        try container.encodeIfPresent(allowedCount, forKey: .allowedCount)
        try container.encodeIfPresent(remainingCount, forKey: .remainingCount)
        try container.encodeIfPresent(redeemed, forKey: .redeemed)
        try container.encodeIfPresent(detail, forKey: .detail)
        try container.encodeIfPresent(validityDays, forKey: .validityDays)
        try container.encodeIfPresent(dataGB, forKey: .dataGB)
    }
}
