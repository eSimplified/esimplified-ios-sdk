//
//  RegisterCustomerResponse.swift
//  KnowRoaming
//
//  Created by Kieran on 2025/02/17.
//

import Foundation

// MARK: Register Customer Response

public struct RegisterCustomerResponse: Codable {
    public var message: String?
    public var success: Bool = false
    public var email: String = ""
    public var referralCode: String?

    public init(message: String? = nil, success: Bool = false, email: String = "", referralCode: String? = nil) {
        self.message = message
        self.success = success
        self.email = email
        self.referralCode = referralCode
    }

    enum CodingKeys: String, CodingKey {
        case message, success, email
        case referralCode = "referral_code"
    }
}
