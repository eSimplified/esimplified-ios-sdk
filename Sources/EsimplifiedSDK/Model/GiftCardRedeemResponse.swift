//
//  GiftCardRedeemResponse.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/11/10.
//

import Foundation

// MARK: Gift Card Preview Request

public struct GiftCardPreviewRequest: Codable {
    public let pin: String

    public init(pin: String) {
        self.pin = pin
    }
}

// MARK: Gift Card Package

public struct GiftCardPackage: Codable, Hashable {
    public let packageTypeId: Int
    public let name: String
    public let country: String?
    public let data: String?
    public let validityDays: Int?

    public init(packageTypeId: Int, name: String, country: String? = nil, data: String? = nil, validityDays: Int? = nil) {
        self.packageTypeId = packageTypeId
        self.name = name
        self.country = country
        self.data = data
        self.validityDays = validityDays
    }

    enum CodingKeys: String, CodingKey {
        case name
        case country
        case data
        case packageTypeId = "package_type_id"
        case validityDays = "validity_days"
    }
}

// MARK: Gift Card Preview Response

public struct GiftCardPreviewResponse: Codable {
    public let package: GiftCardPackage

    public init(package: GiftCardPackage) {
        self.package = package
    }
}

// MARK: Gift Card Redeem Request

public struct GiftCardRedeemRequest: Codable {
    public let pin: String
    public let firstName: String?
    public let lastName: String?
    public let email: String?
    public let marketingOptIn: Bool?
    public let acquisitionSource: String?

    public init(
        pin: String,
        firstName: String? = nil,
        lastName: String? = nil,
        email: String? = nil,
        marketingOptIn: Bool? = nil,
        acquisitionSource: String? = "gift-card"
    ) {
        self.pin = pin
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.marketingOptIn = marketingOptIn
        self.acquisitionSource = acquisitionSource
    }

    enum CodingKeys: String, CodingKey {
        case pin
        case email
        case firstName = "first_name"
        case lastName = "last_name"
        case marketingOptIn = "marketing_opt_in"
        case acquisitionSource = "acquisition_source"
    }
}

// MARK: Gift Card Redeem Response

public struct GiftCardRedeemResponse: Codable {
    public let redeemed: Bool?
    public let success: Bool?
    public let message: String?
    public let email: String?
    public let orderUUID: String?
    public let package: GiftCardPackage?
    public let redirectUrl: String?

    public init(
        redeemed: Bool? = nil,
        success: Bool? = nil,
        message: String? = nil,
        email: String? = nil,
        orderUUID: String? = nil,
        package: GiftCardPackage? = nil,
        redirectUrl: String? = nil
    ) {
        self.redeemed = redeemed
        self.success = success
        self.message = message
        self.email = email
        self.orderUUID = orderUUID
        self.package = package
        self.redirectUrl = redirectUrl
    }

    public var isRedeemed: Bool {
        redeemed == true
    }

    public var awaitsEmailVerification: Bool {
        !isRedeemed && success == true
    }

    enum CodingKeys: String, CodingKey {
        case redeemed
        case success
        case message
        case email
        case package
        case orderUUID = "order_uuid"
        case redirectUrl = "redirect_url"
    }
}
