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
    /// Present when a Mokafaa loyalty election was recorded at signup; absent otherwise
    /// (tenant not Mokafaa-enabled, or the election failed silently — never blocks signup).
    public var mokafaa: MokafaaElection?

    public init(message: String? = nil, success: Bool = false, email: String = "", referralCode: String? = nil, mokafaa: MokafaaElection? = nil) {
        self.message = message
        self.success = success
        self.email = email
        self.referralCode = referralCode
        self.mokafaa = mokafaa
    }

    enum CodingKeys: String, CodingKey {
        case message, success, email, mokafaa
        case referralCode = "referral_code"
    }
}

// MARK: Mokafaa Election

public struct MokafaaElection: Codable {
    public let elected: Bool

    public init(elected: Bool) {
        self.elected = elected
    }
}
