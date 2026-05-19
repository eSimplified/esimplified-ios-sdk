//
//  ChangePasswordResponse.swift
//  KnowRoaming
//
//  Created by Kieran on 2025/03/30.
//

// MARK: Change Password Response

public struct ChangePasswordResponse: Codable {
    public var password_reset: Bool = false

    public init(password_reset: Bool = false) {
        self.password_reset = password_reset
    }

    enum codingKeys: String {
        case passwordReset = "password_reset"
    }
}
