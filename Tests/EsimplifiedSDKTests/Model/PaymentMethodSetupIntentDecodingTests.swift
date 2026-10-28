//
//  PaymentMethodSetupIntentDecodingTests.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/10/22.
//

import Testing
import Foundation
@testable import EsimplifiedSDK

@Suite("PaymentMethodSetupIntent Decoding")
struct PaymentMethodSetupIntentDecodingTests {

    private func decode<T: Decodable>(_ json: String) throws -> T {
        let data = json.data(using: .utf8)!
        return try JSONDecoder().decode(T.self, from: data)
    }

    @Test("Decodes client_secret, customer_id and publishable_key")
    func decodesAllFields() throws {
        let json = #"{"client_secret":"seti_1_secret_2","customer_id":"cus_9","publishable_key":"pk_test_1"}"#
        let intent: PaymentMethodSetupIntent = try decode(json)
        #expect(intent.clientSecret == "seti_1_secret_2")
        #expect(intent.customerID == "cus_9")
        #expect(intent.publishableKey == "pk_test_1")
    }

    @Test("Decodes the setup-intent response as the backend returns it today, without publishable_key")
    func decodesWithoutPublishableKey() throws {
        let json = #"{"client_secret":"seti_1_secret_2","customer_id":"cus_9"}"#
        let intent: PaymentMethodSetupIntent = try decode(json)
        #expect(intent == PaymentMethodSetupIntent(clientSecret: "seti_1_secret_2", customerID: "cus_9"))
        #expect(intent.publishableKey == nil)
    }

    @Test("Treats null customer_id and publishable_key as absent")
    func decodesNullOptionals() throws {
        let json = #"{"client_secret":"seti_1_secret_2","customer_id":null,"publishable_key":null}"#
        let intent: PaymentMethodSetupIntent = try decode(json)
        #expect(intent.clientSecret == "seti_1_secret_2")
        #expect(intent.customerID == nil)
        #expect(intent.publishableKey == nil)
    }

    @Test("Requires client_secret")
    func requiresClientSecret() {
        let json = #"{"customer_id":"cus_9"}"#
        #expect(throws: DecodingError.self) {
            let _: PaymentMethodSetupIntent = try decode(json)
        }
    }

    @Test("Round-trips through the snake_case keys")
    func roundTrips() throws {
        let intent = PaymentMethodSetupIntent(clientSecret: "seti_1_secret_2", customerID: "cus_9", publishableKey: "pk_test_1")
        let data = try JSONEncoder().encode(intent)
        let keys = try #require(try JSONSerialization.jsonObject(with: data) as? [String: Any])
        #expect(keys["client_secret"] as? String == "seti_1_secret_2")
        #expect(keys["customer_id"] as? String == "cus_9")
        #expect(keys["publishable_key"] as? String == "pk_test_1")
        let decoded: PaymentMethodSetupIntent = try decode(String(decoding: data, as: UTF8.self))
        #expect(decoded == intent)
    }
}
