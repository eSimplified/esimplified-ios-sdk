//
//  RegisterUserRequest.swift
//  KnowRoaming
//
//  Created by Kieran on 2025/03/14.
//

import Foundation

// MARK: Register User Request

public struct RegisterUserRequest: Codable {
    public let firstName: String
    public let lastName: String
    public let email: String
    public let mobileNumber: String
    public let password: String
    public let marketingOptIn: String
}
