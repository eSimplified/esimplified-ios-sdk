//
//  ForgotPasswordResponse.swift
//  KnowRoaming
//
//  Created by Kieran on 2025/02/17.
//

import Foundation

// MARK: Forgot Password Response

public struct ForgotPasswordResponse: Codable {
    public var email: String = ""
    public var detail: String = ""
    public var customerID: String? = ""

    public init(email: String = "", detail: String = "", customerID: String? = "") {
        self.email = email
        self.detail = detail
        self.customerID = customerID
    }

    enum CodingKeys: String, CodingKey {
        case detail, email
        case customerID = "customer_id"
    }
}
