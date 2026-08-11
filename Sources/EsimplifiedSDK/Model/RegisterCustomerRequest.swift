//
//  RegisterCustomerRequest.swift
//  KnowRoaming
//
//  Created by Kieran on 2025/07/08.
//

import Foundation

public struct RegisterCustomerRequest: Codable {
    public let firstName: String
    public let lastName: String
    public let email: String
    public let mobileNumber: String
    public let referredBy: String?
    public let password: String
    public let marketingOptIn: Bool?
    public let loyaltyElection: LoyaltyProvider?

    enum CodingKeys: String, CodingKey {
        case email, password
        case firstName = "first_name"
        case lastName = "last_name"
        case mobileNumber = "phone_number"
        case referredBy = "referred_by"
        case marketingOptIn = "marketing_opt_in"
        case loyaltyElection = "loyalty_election"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(email, forKey: .email)
        try container.encode(mobileNumber, forKey: .mobileNumber)
        try container.encodeIfPresent(referredBy, forKey: .referredBy)
        try container.encode(password, forKey: .password)
        try container.encodeIfPresent(marketingOptIn, forKey: .marketingOptIn)
        try container.encodeIfPresent(loyaltyElection, forKey: .loyaltyElection)
    }

    public init(firstName: String, lastName: String, email: String, mobileNumber: String, referredBy: String?, password: String, marketingOptIn: Bool?, loyaltyElection: LoyaltyProvider? = nil) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.mobileNumber = mobileNumber
        self.referredBy = referredBy
        self.password = password
        self.marketingOptIn = marketingOptIn
        self.loyaltyElection = loyaltyElection
    }
}
