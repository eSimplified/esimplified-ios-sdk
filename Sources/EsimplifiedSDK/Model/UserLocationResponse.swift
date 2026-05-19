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
}

public struct LocationDetails: Codable {
    public var country: String?
    public var countryCode: String?
    public var city: String?
    public var lat: Double?
    public var lon: Double?
    public var timezone: String?
}
