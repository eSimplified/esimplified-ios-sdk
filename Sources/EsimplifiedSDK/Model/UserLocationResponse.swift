//
//  UserLocationResponse.swift
//  KnowRoaming
//
//  Created by Kieran on 2025/02/17.
//

import Foundation

// MARK: User Location Response

public struct UserLocationResponse: Codable {
    public var location: LocationDetails?

    public init(location: LocationDetails? = nil) {
        self.location = location
    }
}

public struct LocationDetails: Codable {
    public var country: String?
    public var countryCode: String?
    public var city: String?
    public var lat: Double?
    public var lon: Double?
    public var timezone: String?

    public init(country: String? = nil, countryCode: String? = nil, city: String? = nil, lat: Double? = nil, lon: Double? = nil, timezone: String? = nil) {
        self.country = country
        self.countryCode = countryCode
        self.city = city
        self.lat = lat
        self.lon = lon
        self.timezone = timezone
    }
}
