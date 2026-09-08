//
//  DefaultFalse.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/09/07.
//

import Foundation

// MARK: Default False

@propertyWrapper
public struct DefaultFalse: Codable, Hashable, Sendable {
    public var wrappedValue: Bool

    public init(wrappedValue: Bool = false) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        wrappedValue = (try? container.decode(Bool.self)) ?? false
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}

public extension KeyedDecodingContainer {
    func decode(_ type: DefaultFalse.Type, forKey key: Key) throws -> DefaultFalse {
        try decodeIfPresent(DefaultFalse.self, forKey: key) ?? DefaultFalse()
    }
}
