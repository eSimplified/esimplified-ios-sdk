//
//  CheckStockResponse.swift
//  EsimplifiedSDK
//

import Foundation

// MARK: Check Stock Response

public struct CheckStockResponse: Codable {
    public let stock: Bool
    public let package: Package
    public var promoCode: PromoCodeResponse?

    public enum CodingKeys: String, CodingKey {
        case stock, package
        case promoCode = "promo_code"
    }
}
