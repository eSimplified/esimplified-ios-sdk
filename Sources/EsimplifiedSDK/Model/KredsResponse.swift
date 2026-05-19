//
//  KredsResponse.swift
//  KnowRoaming
//
//  Created by Kieran on 2025/02/25.
//

import Foundation

// MARK: Kreds Loyalty Balance Response

public struct KredsLoyaltyBalanceResponse: Codable {
    public let totalLoyaltyPoints: Int
    public let totalLoyaltyPointsDetail: LoyaltyPointsDetail

    public init(totalLoyaltyPoints: Int, totalLoyaltyPointsDetail: LoyaltyPointsDetail) {
        self.totalLoyaltyPoints = totalLoyaltyPoints
        self.totalLoyaltyPointsDetail = totalLoyaltyPointsDetail
    }

    enum CodingKeys: String, CodingKey {
        case totalLoyaltyPoints = "total_loyalty_points"
        case totalLoyaltyPointsDetail = "total_loyalty_points_detail"
    }
}

// MARK: Loyalty Points Detail

public struct LoyaltyPointsDetail: Codable {
    public let amount: String
    public let amountLocalCurrency: String?
    public let amountLocalCurrencyCents: Int?
    public let currency: Currency
    public let original: LoyaltyPointsOriginal?

    enum CodingKeys: String, CodingKey {
        case amount, currency, original
        case amountLocalCurrency = "amount_local_currency"
        case amountLocalCurrencyCents = "amount_local_currency_cents"
    }

    public init(
        amount: String,
        amountLocalCurrency: String? = nil,
        amountLocalCurrencyCents: Int? = nil,
        currency: Currency,
        original: LoyaltyPointsOriginal? = nil
    ) {
        self.amount = amount
        self.amountLocalCurrency = amountLocalCurrency
        self.amountLocalCurrencyCents = amountLocalCurrencyCents
        self.currency = currency
        self.original = original
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        amountLocalCurrency = try container.decodeIfPresent(String.self, forKey: .amountLocalCurrency)
        amountLocalCurrencyCents = try container.decodeIfPresent(Int.self, forKey: .amountLocalCurrencyCents)
        currency = try container.decode(Currency.self, forKey: .currency)
        original = try container.decodeIfPresent(LoyaltyPointsOriginal.self, forKey: .original)

        if let explicitAmount = try container.decodeIfPresent(String.self, forKey: .amount) {
            amount = explicitAmount
        } else if let localAmount = amountLocalCurrency {
            amount = localAmount
        } else if let usdAmount = original?.amountUSD {
            amount = usdAmount
        } else {
            amount = "0.00"
        }
    }
}

public struct LoyaltyPointsOriginal: Codable {
    public let amountUSD: String
    public let currency: Currency

    public init(amountUSD: String, currency: Currency) {
        self.amountUSD = amountUSD
        self.currency = currency
    }

    enum CodingKeys: String, CodingKey {
        case amountUSD = "amount_usd"
        case currency
    }
}
