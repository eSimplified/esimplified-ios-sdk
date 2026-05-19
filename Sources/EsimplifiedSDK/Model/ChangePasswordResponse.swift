//
//  ChangePasswordResponse.swift
//  EsimplifiedSDK
//

import Foundation

// MARK: Change Password Response

public struct ChangePasswordResponse: Codable {
    public var passwordReset: Bool = false

    public enum CodingKeys: String, CodingKey {
        case passwordReset = "password_reset"
    }

    public init(passwordReset: Bool = false) {
        self.passwordReset = passwordReset
    }
}
