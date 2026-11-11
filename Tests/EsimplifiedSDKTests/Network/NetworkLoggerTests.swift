//
//  NetworkLoggerTests.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/11/11.
//

import Foundation
import Testing
@testable import EsimplifiedSDK

@Suite("Network Logger")
struct NetworkLoggerTests {

    @Test("A gift-card request body logs the PIN and personal details redacted")
    func giftCardRequestIsRedacted() throws {
        let raw = #"{"pin":"99954819342337407","first_name":"Ada","last_name":"Lovelace","email":"ada@example.com","marketing_opt_in":true,"acquisition_source":"gift-card"}"#

        let logged = NetworkLogger.redactBody(raw: raw, contentType: "application/json")

        #expect(!logged.contains("99954819342337407"))
        #expect(!logged.contains("ada@example.com"))
        #expect(!logged.contains("Lovelace"))
        #expect(logged.contains("***REDACTED***"))
        #expect(logged.contains("gift-card"))
    }

    @Test("A gift-card response logs the package but not the customer's email")
    func giftCardResponseIsRedacted() throws {
        let raw = #"{"success":true,"message":"Check your email","customer_id":42,"email":"new@example.com","order_uuid":"9a2c","package":{"name":"Australia 3 GB 10 Days"}}"#

        let logged = NetworkLogger.redactBody(raw: raw, contentType: "application/json")

        #expect(!logged.contains("new@example.com"))
        #expect(logged.contains("Australia 3 GB 10 Days"))
        #expect(logged.contains("9a2c"))
    }

    @Test("A profile response logs names and phone numbers redacted")
    func profileIsRedacted() throws {
        let raw = #"{"first_name":"Ada","last_name":"Lovelace","email":"ada@example.com","mobile_number":"+27821234567","preferred_currency":"ZAR"}"#

        let logged = NetworkLogger.redactBody(raw: raw, contentType: "application/json")

        #expect(!logged.contains("Ada"))
        #expect(!logged.contains("+27821234567"))
        #expect(logged.contains("ZAR"))
    }
}
