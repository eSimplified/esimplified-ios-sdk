//
//  UpdateEsimResponse.swift
//  KnowRoaming
//
//  Created by Kieran on 2025/05/29.
//

import Foundation

// MARK: Update Esim Response

public struct UpdateEsimResponse: Codable {
    public var message: String?

    public init(message: String? = nil) {
        self.message = message
    }
}
