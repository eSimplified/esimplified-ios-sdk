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

    public init(stock: Bool, package: Package, promoCode: PromoCodeResponse? = nil) {
        self.stock = stock
        self.package = package
        self.promoCode = promoCode
    }

    enum CodingKeys: String, CodingKey {
        case stock, package
        case promoCode = "promo_code"
    }
}
