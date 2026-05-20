//
//  RegisterUserRequest.swift
//  KnowRoaming
//
//  Created by Kieran on 2025/03/14.
//

import Foundation

// MARK: User Registration Request

public struct UserRegistrationRequest {
    public let firstName: String
    public let lastName: String
    public let email: String
    public let mobileNumber: String
    public let password: String
    public let marketingOptIn: Bool

    public init(firstName: String, lastName: String, email: String, mobileNumber: String, password: String, marketingOptIn: Bool) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.mobileNumber = mobileNumber
        self.password = password
        self.marketingOptIn = marketingOptIn
    }
}
