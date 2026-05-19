//
//  RestrictedCountryModels.swift
//  EsimplifiedSDK
//

import Foundation

// MARK: Restriction Type Enum

public enum RestrictionType: String, Codable {
    case global
    case local
}

// MARK: Restricted For Model

public struct RestrictedFor: Codable {
    public let countryCode: String
    public let countryName: String

    public enum CodingKeys: String, CodingKey {
        case countryCode = "country_code"
        case countryName = "country_name"
    }

    public init(countryCode: String, countryName: String) {
        self.countryCode = countryCode
        self.countryName = countryName
    }
}

// MARK: Restricted Country Model

public struct RestrictedCountry: Codable {
    public let countryCode: String
    public let restrictionType: RestrictionType
    public let restrictedFor: [RestrictedFor]?

    public enum CodingKeys: String, CodingKey {
        case countryCode = "country_code"
        case restrictionType = "restriction_type"
        case restrictedFor = "restricted_for"
    }

    public init(countryCode: String, restrictionType: RestrictionType, restrictedFor: [RestrictedFor]? = nil) {
        self.countryCode = countryCode
        self.restrictionType = restrictionType
        self.restrictedFor = restrictedFor
    }
}
