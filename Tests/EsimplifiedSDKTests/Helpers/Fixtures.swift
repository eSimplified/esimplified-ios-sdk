//
//  Fixtures.swift
//  EsimplifiedSDK
//  Created by Zivaiishe Kanengoni on 2026/09/09.
//

import Foundation
@testable import EsimplifiedSDK

enum Fixtures {

    struct MissingFixture: Error {
        let name: String
    }

    static func data(_ name: String) throws -> Data {
        guard let url = Bundle.module.url(forResource: name, withExtension: "json", subdirectory: "Fixtures") else {
            throw MissingFixture(name: name)
        }
        return try Data(contentsOf: url)
    }

    static func decode<T: Decodable>(_ name: String) throws -> T {
        try JSONDecoder().decode(T.self, from: data(name))
    }

    static func content(_ name: String) throws -> ContentDocument {
        try decode(name)
    }
}
