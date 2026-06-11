//
//  EsimplifiedSDKTests.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/06/04.
//

import Testing
@testable import EsimplifiedSDK

@Suite("SDK Version")
struct EsimplifiedSDKTests {
    @Test("Version is 1.0.2")
    func version() {
        #expect(EsimplifiedSDKVersion.version == "1.0.2")
    }
}
