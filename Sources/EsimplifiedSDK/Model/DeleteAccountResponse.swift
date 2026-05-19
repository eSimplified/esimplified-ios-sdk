//
//  DeleteAccountResponse.swift
//  EsimplifiedSDK
//

import Foundation

// MARK: Delete Account Response

public struct DeleteAccountResponse: Codable {
    public var deleted: Bool = false

    public init(deleted: Bool = false) {
        self.deleted = deleted
    }
}
