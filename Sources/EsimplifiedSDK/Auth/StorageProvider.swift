//
//  StorageProvider.swift
//  EsimplifiedSDK
//
//  Created by Kieran on 2026/06/04.
//

import Foundation

public protocol StorageProvider {
    func save(_ value: String, forKey key: String) throws
    func retrieve(forKey key: String) -> String?
    func delete(forKey key: String) throws
    func clear() throws
}
