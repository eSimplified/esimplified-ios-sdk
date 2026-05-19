//
//  PromocodeResponse.swift
//  EsimplifiedSDK
//

import Foundation

// MARK: Promo Code Response

public struct PromoCodeResponse: Codable, Hashable {
    public var isValid: Bool
    public let discountCode: String
    public let discountPercentage: Double
    public let detail: String
    public let productType: String?

    public enum CodingKeys: String, CodingKey {
        case detail
        case isValid = "valid"
        case discountCode = "discount_code"
        case discountPercentage = "discount_percentage"
        case productType = "product_type"
    }

    public init(isValid: Bool, discountCode: String, discountPercentage: Double,
                detail: String, productType: String? = nil) {
        self.isValid = isValid
        self.discountCode = discountCode
        self.discountPercentage = discountPercentage
        self.detail = detail
        self.productType = productType
    }
}
