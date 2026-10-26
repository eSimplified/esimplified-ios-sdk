//
//  PaymentMethodSetupIntent.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/10/22.
//

import Foundation

// MARK: Payment Method Setup Intent

public struct PaymentMethodSetupIntent: Codable, Equatable {
    public let clientSecret: String
    public let customerID: String?
    public let publishableKey: String?

    public init(clientSecret: String, customerID: String? = nil, publishableKey: String? = nil) {
        self.clientSecret = clientSecret
        self.customerID = customerID
        self.publishableKey = publishableKey
    }

    enum CodingKeys: String, CodingKey {
        case clientSecret = "client_secret"
        case customerID = "customer_id"
        case publishableKey = "publishable_key"
    }
}
