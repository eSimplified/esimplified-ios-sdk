//
//  PackageResponse.swift
//  KnowRoaming
//
//  Created by Kieran on 2024/09/26.
//

import Foundation

// MARK: Package Response

public struct PackageResponse: Codable {
    public let count: Int
    public let next: String?
    public let previous: String?
    public let promoCode: PromoCodeResponse?
    public let packages: [Package]

    enum CodingKeys: String, CodingKey {
        case count, next, previous
        case promoCode = "promo_code"
        case packages = "results"
    }
}

// MARK: Package Model

public struct Package: Codable, Hashable {
    public let name: String
    public let price: String
    public let convertedPrice: Double?
    public let dataGB: String
    public let country: Country
    public let network: [String]?
    public let currency: String
    public let currencyObject: Currency
    public let planType: String
    public let kycDisplay: String
    public let packageSlug: String
    public let validityDays: Int
    public let validityDaysDisplay: String
    public let packageTypeID: Int
    public let bestConnectivity: String
    public let activationPolicy: String
    public let supportedCountries: [SupportedCountry]?
    public let nameAdditionalText: String
    public let discountLabel: String
    public let discountedPrice: String?
    public let discountPercentage: String?
    public let earnPercentage: Double?
    public let promoCode: PromoCodeResponse?
    public let dataCap: String?
    public let throttleSpeed: String?

    public var hasAddedPromoCode: Bool {
        discountedPrice != nil
    }

    public var formattedDataAndValidity: String {
        name.formattedPackageName
    }

    public var formattedData: String {
        hasUnlimitedPackage ? "Unlimited" : "\((dataGB.dropLast(3))) GB"
    }

    public var hasUnlimitedPackage: Bool {
        dataGB == "-1.00"
    }

    enum CodingKeys: String, CodingKey {
        case name, price, country, network, currency
        case dataGB = "data_GB"
        case currencyObject = "currency_obj"
        case planType = "plan_type"
        case kycDisplay = "kyc_display"
        case packageSlug = "package_slug"
        case validityDays = "validity_days"
        case validityDaysDisplay = "validity_days_display"
        case packageTypeID = "package_type_id"
        case bestConnectivity = "best_connectivity"
        case activationPolicy = "activation_policy"
        case supportedCountries = "supported_countries"
        case nameAdditionalText = "name_additional_text"
        case convertedPrice = "converted_price"
        case discountLabel = "discount_label"
        case discountedPrice = "discounted_price"
        case discountPercentage = "discount_percentage"
        case promoCode = "promo_code"
        case dataCap = "data_cap"
        case throttleSpeed = "throttle_speed"
        case earnPercentage = "earn_percentage"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        price = try container.decode(String.self, forKey: .price)
        convertedPrice = try container.decodeIfPresent(Double.self, forKey: .convertedPrice)
        dataGB = try container.decode(String.self, forKey: .dataGB)
        network = try container.decodeIfPresent([String].self, forKey: .network)
        currency = try container.decode(String.self, forKey: .currency)
        currencyObject = try container.decode(Currency.self, forKey: .currencyObject)
        planType = try container.decode(String.self, forKey: .planType)
        kycDisplay = try container.decode(String.self, forKey: .kycDisplay)
        packageSlug = try container.decode(String.self, forKey: .packageSlug)
        validityDays = try container.decode(Int.self, forKey: .validityDays)
        validityDaysDisplay = try container.decode(String.self, forKey: .validityDaysDisplay)
        packageTypeID = try container.decode(Int.self, forKey: .packageTypeID)
        bestConnectivity = try container.decode(String.self, forKey: .bestConnectivity)
        activationPolicy = try container.decode(String.self, forKey: .activationPolicy)
        supportedCountries = (try? container.decode([SupportedCountry].self, forKey: .supportedCountries)) ?? []
        nameAdditionalText = try container.decode(String.self, forKey: .nameAdditionalText)
        discountLabel = try container.decode(String.self, forKey: .discountLabel)
        discountPercentage = try container.decodeIfPresent(String.self, forKey: .discountPercentage)
        promoCode = try container.decodeIfPresent(PromoCodeResponse.self, forKey: .promoCode)
        dataCap = try container.decodeIfPresent(String.self, forKey: .dataCap)
        throttleSpeed = try container.decodeIfPresent(String.self, forKey: .throttleSpeed)
        earnPercentage = try container.decodeIfPresent(Double.self, forKey: .earnPercentage)

        if container.contains(.discountedPrice) {
            let rawValue = try container.decode(AnyCodable.self, forKey: .discountedPrice).value
            switch rawValue {
            case let string as String:
                discountedPrice = string
            case let double as Double:
                discountedPrice = String(double)
            case let int as Int:
                discountedPrice = String(int)
            default:
                discountedPrice = nil
            }
        } else {
            discountedPrice = nil
        }

        if let countryObject = try? container.decode(Country.self, forKey: .country) {
            country = countryObject
        } else {
            let countryName = try container.decode(String.self, forKey: .country)
            country = Country(countryName: countryName)
        }
    }
}

// MARK: Currency Model

public struct Currency: Codable, Hashable {
    public let symbol: String
    public let iso: String
}

// MARK: Supported Country Model

public struct SupportedCountry: Codable, Hashable {
    public let countryName: String
    public let countryCode: String

    enum CodingKeys: String, CodingKey {
        case countryName = "country_name"
        case countryCode = "country_code"
    }
}

// Helper to decode Any type
private struct AnyCodable: Decodable {
    let value: Any

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            value = string
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Cannot decode value as String, Double, or Int"
            )
        }
    }
}
