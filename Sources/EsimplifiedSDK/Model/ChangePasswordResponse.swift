//
//  ChangePasswordResponse.swift
//  KnowRoaming
//
//  Created by Kieran on 2025/03/30.
//

// MARK: Change Password Response

public struct ChangePasswordResponse: Codable {
    public var password_reset: Bool = false

    enum codingKeys: String {
        case passwordReset = "password_reset"
    }
}
