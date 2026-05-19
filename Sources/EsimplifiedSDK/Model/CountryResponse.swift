//
//  CountriesResponse.swift
//  KnowRoaming
//
//  Created by Kieran on 2024/09/26.
//

import Foundation

// MARK: Country Response

public struct CountryResponse: Codable {
    public let count: Int
    public let next: String?
    public let previous: String?
    public let countries: [Country]

    public init(count: Int, next: String? = nil, previous: String? = nil, countries: [Country]) {
        self.count = count
        self.next = next
        self.previous = previous
        self.countries = countries
    }

    enum CodingKeys: String, CodingKey {
        case count, next, previous
        case countries = "results"
    }
}

// MARK: Country Model

public struct Country: Codable, Hashable, Identifiable {
    public let id = UUID()
    public let countryName: String
    public let countryNameSlug: String
    public let countryCode: String
    public let countryFlag: String
    public let countryFlagCss: String
    public let isRegion: Bool
    public let fromPrice: String?
    public let currency: String?
    public let currencyObject: Currency?

    public init(
        countryName: String,
        countryNameSlug: String,
        countryCode: String,
        countryFlag: String,
        countryFlagCss: String,
        isRegion: Bool,
        fromPrice: String? = nil,
        currency: String? = nil,
        currencyObject: Currency? = nil
    ) {
        self.countryName = countryName
        self.countryNameSlug = countryNameSlug
        self.countryCode = countryCode
        self.countryFlag = countryFlag
        self.countryFlagCss = countryFlagCss
        self.isRegion = isRegion
        self.fromPrice = fromPrice
        self.currency = currency
        self.currencyObject = currencyObject
    }

    enum CodingKeys: String, CodingKey {
        case countryName = "country_name"
        case countryNameSlug = "country_name_slug"
        case countryCode = "country_code"
        case countryFlag = "country_flag"
        case countryFlagCss = "country_flag_css"
        case isRegion = "is_region"
        case fromPrice = "from_price"
        case currencyObject = "currency_obj"
        case currency
    }
}

extension Country {
    public init(countryName: String) {
        self.countryName = countryName
        self.countryNameSlug = ""
        self.countryCode = ""
        self.countryFlag = ""
        self.countryFlagCss = ""
        self.isRegion = false
        self.fromPrice = nil
        self.currency = nil
        self.currencyObject = nil
    }
}

// USED for deeplinks
extension Country {
    public init(countryName: String, countryNameSlug: String, countryCode: String) {
        self.countryName = countryName
        self.countryNameSlug = countryNameSlug
        self.countryCode = countryCode
        self.countryFlag = ""
        self.countryFlagCss = ""
        self.isRegion = false
        self.fromPrice = nil
        self.currency = nil
        self.currencyObject = nil
    }
}
