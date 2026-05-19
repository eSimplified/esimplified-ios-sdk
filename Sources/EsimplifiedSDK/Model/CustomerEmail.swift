//
//  CustomerEmail.swift
//  KnowRoaming
//
//  Created by Kieran on 2025/06/21.
//

import Foundation

// MARK: Customer Email Model

public struct CustomerEmail: Codable {
    public let email: String

    public init(email: String) {
        self.email = email
    }
}
