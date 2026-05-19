//
//  VerifyEmailResponse.swift
//  KnowRoaming
//
//  Created by Kieran on 2025/02/17.
//

import Foundation

// MARK: Verify Email Response

public struct VerifyEmailResponse: Codable {
    public var email: String = ""
    public var email_verified: Bool = false
}
