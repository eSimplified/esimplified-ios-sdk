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

    enum CodingKeys: String, CodingKey {
        case message, success, email
        case referralCode = "referral_code"
    }
}
