//
//  RegisterCustomerRequest.swift
//  EsimplifiedSDK
//

import Foundation

// MARK: Register Customer Request

public struct RegisterCustomerRequest: Encodable {
    public let firstName: String
    public let lastName: String
    public let email: String
    public let mobileNumber: String
    public let referredBy: String?
    public let password: String
    public let marketingOptIn: Bool

    public enum CodingKeys: String, CodingKey {
        case email, password
        case firstName = "first_name"
        case lastName = "last_name"
        case mobileNumber = "phone_number"
        case referredBy = "referred_by"
        case marketingOptIn = "marketing_opt_in"
    }

    public init(firstName: String, lastName: String, email: String, mobileNumber: String,
                referredBy: String? = nil, password: String, marketingOptIn: Bool) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.mobileNumber = mobileNumber
        self.referredBy = referredBy
        self.password = password
        self.marketingOptIn = marketingOptIn
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(email, forKey: .email)
        try container.encode(mobileNumber, forKey: .mobileNumber)
        try container.encodeIfPresent(referredBy, forKey: .referredBy)
        try container.encode(password, forKey: .password)
        try container.encode(marketingOptIn, forKey: .marketingOptIn)
    }
}
