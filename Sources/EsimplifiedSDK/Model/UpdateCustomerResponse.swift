//
//  UpdateCustomerResponse.swift
//  KnowRoaming
//
//  Created by Kieran on 2025/02/17.
//

import Foundation

// MARK: Update Customer Response

public struct UpdateCustomerResponse: Codable {
    public var updated: Bool = false
    public var customer: User? = User()
}

// MARK: Update Customer Request

public struct UpdateCustomerRequest: Encodable {
    public var firstName: String?
    public var lastName: String?
    public var email: String?
    public var phoneNumber: String?
    public var password: String?

    enum CodingKeys: String, CodingKey {
        case password
        case firstName = "first_name"
        case lastName = "last_name"
        case phoneNumber = "phone_number"
        case email = "new_email"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(password, forKey: .password)
        try container.encodeIfPresent(firstName, forKey: .firstName)
        try container.encodeIfPresent(lastName, forKey: .lastName)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encodeIfPresent(phoneNumber, forKey: .phoneNumber)
    }

    public init(firstName: String? = nil, lastName: String? = nil, email: String? = nil, phoneNumber: String? = nil, password: String? = nil) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phoneNumber = phoneNumber
        self.password = password
    }
}
