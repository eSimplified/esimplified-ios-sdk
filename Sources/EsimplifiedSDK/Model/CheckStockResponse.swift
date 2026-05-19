//
//  CheckStockResponse.swift
//  KnowRoaming
//
//  Created by Kieran on 2025/04/05.
//

import Foundation

// MARK: Check Stock Response

public struct CheckStockResponse: Codable {
    public let stock: Bool
    public let package: Package
    public var promoCode: PromoCodeResponse?

    enum CodingKeys: String, CodingKey {
        case stock, package
        case promoCode = "promo_code"
    }
}
