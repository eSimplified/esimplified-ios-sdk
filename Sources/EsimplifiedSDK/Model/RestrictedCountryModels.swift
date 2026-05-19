//
//  RestrictedCountryModels.swift
//  KnowRoaming
//
//  Created on 2025/01/XX.
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

    enum CodingKeys: String, CodingKey {
        case countryCode = "country_code"
        case countryName = "country_name"
    }
}

// MARK: Restricted Country Model

public struct RestrictedCountry: Codable {
    public let countryCode: String
    public let restrictionType: RestrictionType
    public let restrictedFor: [RestrictedFor]?

    enum CodingKeys: String, CodingKey {
        case countryCode = "country_code"
        case restrictionType = "restriction_type"
        case restrictedFor = "restricted_for"
    }
}
