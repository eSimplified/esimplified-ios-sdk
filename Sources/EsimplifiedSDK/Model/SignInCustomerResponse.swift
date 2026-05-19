//
//  SignInCustomerResponse.swift
//  KnowRoaming
//
//  Created by Kieran on 2025/02/17.
//

import Foundation

// MARK: Sign In Customer Response

public struct SignInCustomerResponse: Codable {
    public var accessToken: String = ""
    public var tokenExpiresIn: Int = 0
    public var tokenType: String = ""
    public var scope: String = ""
    public var refreshToken: String? = ""
    public var user: User? = User()

    enum CodingKeys: String, CodingKey {
        case user, scope
        case accessToken = "access_token"
        case tokenExpiresIn = "expires_in"
        case tokenType = "token_type"
        case refreshToken = "refresh_token"
    }
}
