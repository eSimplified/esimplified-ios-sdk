//
//  UpdateCustomerPreferenceResponse.swift
//  KnowRoaming
//
//  Created by Kieran on 2025/11/19.
//

import Foundation

// MARK: Update Customer Request

public struct UpdateCustomerPreferencesRequest: Encodable {
    public var preferredLanguage: String?
    public var preferredCurrency: String?

    enum CodingKeys: String, CodingKey {
        case preferredLanguage = "preferred_language"
        case preferredCurrency = "preferred_currency"
    }

    public init(preferredLanguage: String? = nil, preferredCurrency: String? = nil) {
        self.preferredLanguage = preferredLanguage
        self.preferredCurrency = preferredCurrency
    }
}
