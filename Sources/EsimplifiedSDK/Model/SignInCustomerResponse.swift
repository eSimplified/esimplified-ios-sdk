//
//  SignInCustomerResponse.swift
//  EsimplifiedSDK
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

    public enum CodingKeys: String, CodingKey {
        case user, scope
        case accessToken = "access_token"
        case tokenExpiresIn = "expires_in"
        case tokenType = "token_type"
        case refreshToken = "refresh_token"
    }

    public init(accessToken: String = "", tokenExpiresIn: Int = 0, tokenType: String = "",
                scope: String = "", refreshToken: String? = "", user: User? = User()) {
        self.accessToken = accessToken
        self.tokenExpiresIn = tokenExpiresIn
        self.tokenType = tokenType
        self.scope = scope
        self.refreshToken = refreshToken
        self.user = user
    }
}
