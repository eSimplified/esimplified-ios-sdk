//
//  UpdateEsimResponse.swift
//  EsimplifiedSDK
//

import Foundation

// MARK: Update Esim Response

public struct UpdateEsimResponse: Codable {
    public var message: String?

    public init(message: String? = nil) {
        self.message = message
    }
}
