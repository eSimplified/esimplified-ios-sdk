//
//  DeletePaymentMethodResponse.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/10/28.
//

import Foundation

// MARK: Delete Payment Method Response

public struct DeletePaymentMethodResponse: Codable, Equatable {
    public let detail: String?

    public init(detail: String? = nil) {
        self.detail = detail
    }
}
