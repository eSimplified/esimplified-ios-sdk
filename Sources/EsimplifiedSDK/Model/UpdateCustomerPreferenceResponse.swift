//
//  UpdateCustomerPreferenceResponse.swift
//  EsimplifiedSDK
//

import Foundation

// MARK: Update Customer Preferences Request

public struct UpdateCustomerPreferencesRequest: Encodable {
    public var preferredLanguage: String?
    public var preferredCurrency: String?

    public enum CodingKeys: String, CodingKey {
        case preferredLanguage = "preferred_language"
        case preferredCurrency = "preferred_currency"
    }

    public init(preferredLanguage: String? = nil, preferredCurrency: String? = nil) {
        self.preferredLanguage = preferredLanguage
        self.preferredCurrency = preferredCurrency
    }
}
