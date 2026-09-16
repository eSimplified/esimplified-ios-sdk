//
//  EsimplifiedSDKTests.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/06/04.
//

import Testing
@testable import EsimplifiedSDK

@Suite("SDK Version")
struct EsimplifiedSDKTests {
    @Test("Version is a release number the tagger can use")
    func version() {
        let components = EsimplifiedSDKVersion.version.split(separator: ".")
        #expect(components.count == 3)
        #expect(components.allSatisfy { Int($0) != nil })
    }
}
