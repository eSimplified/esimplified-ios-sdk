//
//  MockStorageProvider.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/06/04.
//

import Foundation
@testable import EsimplifiedSDK

class MockStorageProvider: StorageProvider {
    var store: [String: String] = [:]

    func save(_ value: String, forKey key: String) throws {
        store[key] = value
    }
    func retrieve(forKey key: String) -> String? {
        store[key]
    }
    func delete(forKey key: String) throws {
        store.removeValue(forKey: key)
    }
    func clear() throws {
        store.removeAll()
    }
}
