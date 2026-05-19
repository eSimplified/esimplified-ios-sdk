//
//  ForgotPasswordResponse.swift
//  EsimplifiedSDK
//

import Foundation

// MARK: Forgot Password Response

public struct ForgotPasswordResponse: Codable {
    public var email: String = ""
    public var detail: String = ""
    public var customerID: String? = ""

    public enum CodingKeys: String, CodingKey {
        case detail, email
        case customerID = "customer_id"
    }

    public init(email: String = "", detail: String = "", customerID: String? = "") {
        self.email = email
        self.detail = detail
        self.customerID = customerID
    }
}
