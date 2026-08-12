//
//  SdkConfigTests.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/06/04.
//

import Foundation
import Testing
@testable import EsimplifiedSDK

@Suite("SdkConfig")
struct SdkConfigTests {

    @Test("Default values are correct")
    func defaults() {
        let config = SdkConfig(
            environment: .production,
            clientName: "test",
            clientId: "id",
            clientSecret: "secret"
        )
        #expect(config.apiVersion == "v2")
        #expect(config.awsWafToken == "")
        #expect(!config.enableLogging)
        #expect(config.customHeadersProvider == nil)
    }

    @Test("Staging base URL uses client name")
    func stagingURL() {
        let config = SdkConfig(
            environment: .staging,
            clientName: "acme",
            clientId: "id",
            clientSecret: "secret"
        )
        #expect(config.baseURL == "https://acme.stage.esimplified.io")
    }

    @Test("Testing base URL uses client name")
    func testingURL() {
        let config = SdkConfig(
            environment: .testing,
            clientName: "acme",
            clientId: "id",
            clientSecret: "secret"
        )
        #expect(config.baseURL == "https://acme.test.esimplified.io")
    }

    @Test("Production base URL uses client name")
    func productionURL() {
        let config = SdkConfig(
            environment: .production,
            clientName: "acme",
            clientId: "id",
            clientSecret: "secret"
        )
        #expect(config.baseURL == "https://acme.live.esimplified.io")
    }

    @Test("Logging can be enabled")
    func loggingEnabled() {
        let config = SdkConfig(
            environment: .staging,
            clientName: "test",
            clientId: "id",
            clientSecret: "secret",
            enableLogging: true
        )
        #expect(config.enableLogging)
    }
}

@Suite("AuthState")
struct AuthStateTests {

    @Test("Unauthenticated state returns nil tokens")
    func unauthenticated() {
        let state = AuthState.unauthenticated
        #expect(!state.isAuthenticated)
        #expect(state.accessToken == nil)
        #expect(state.refreshToken == nil)
        #expect(state.isExpired)
    }

    @Test("Authenticated state returns tokens")
    func authenticated() {
        let state = AuthState.authenticated(
            accessToken: "access",
            refreshToken: "refresh",
            expiresAt: Date().addingTimeInterval(3600)
        )
        #expect(state.isAuthenticated)
        #expect(state.accessToken == "access")
        #expect(state.refreshToken == "refresh")
        #expect(!state.isExpired)
    }

    @Test("Token is expired when within 5 minute buffer")
    func expiredWithBuffer() {
        let state = AuthState.authenticated(
            accessToken: "access",
            refreshToken: "refresh",
            expiresAt: Date().addingTimeInterval(200)
        )
        #expect(state.isExpired)
    }
}

@Suite("SdkError")
struct SdkErrorTests {

    @Test("Network error has description")
    func networkError() {
        let error = SdkError.networkError(statusCode: 404, message: "Not Found")
        #expect(error.errorDescription == "Not Found")
    }

    @Test("Authentication required has description")
    func authRequired() {
        let error = SdkError.authenticationRequired
        #expect(error.errorDescription == "Authentication required")
    }
}
