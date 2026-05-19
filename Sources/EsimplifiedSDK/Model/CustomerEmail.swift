//
//  CustomerEmail.swift
//  EsimplifiedSDK
//

import Foundation

// MARK: Customer Email Model

public struct CustomerEmail: Codable {
    public let email: String

    public init(email: String) {
        self.email = email
    }
}
