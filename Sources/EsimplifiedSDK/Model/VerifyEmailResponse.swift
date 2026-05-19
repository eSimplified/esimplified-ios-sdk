//
//  VerifyEmailResponse.swift
//  EsimplifiedSDK
//

import Foundation

// MARK: Verify Email Response

public struct VerifyEmailResponse: Codable {
    public var email: String = ""
    public var emailVerified: Bool = false

    public enum CodingKeys: String, CodingKey {
        case email
        case emailVerified = "email_verified"
    }

    public init(email: String = "", emailVerified: Bool = false) {
        self.email = email
        self.emailVerified = emailVerified
    }
}
