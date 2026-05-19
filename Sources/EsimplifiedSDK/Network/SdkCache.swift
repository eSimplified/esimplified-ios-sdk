//
//  SdkCache.swift
//  EsimplifiedSDK
//

import Foundation

final class SdkCache {
    private var store: [String: CacheEntry] = [:]
    private let defaultTTL: TimeInterval

    struct CacheEntry {
        let data: Any
        let expiresAt: Date
        var isExpired: Bool { Date() >= expiresAt }
    }

    init(defaultTTL: TimeInterval = 3600) {
        self.defaultTTL = defaultTTL
    }

    func get<T>(_ key: String) -> T? {
        guard let entry = store[key], !entry.isExpired else {
            store.removeValue(forKey: key)
            return nil
        }
        return entry.data as? T
    }

    func set(_ key: String, value: Any, ttl: TimeInterval? = nil) {
        let expiry = Date().addingTimeInterval(ttl ?? defaultTTL)
        store[key] = CacheEntry(data: value, expiresAt: expiry)
    }

    func remove(_ key: String) {
        store.removeValue(forKey: key)
    }

    func clear() {
        store.removeAll()
    }
}
