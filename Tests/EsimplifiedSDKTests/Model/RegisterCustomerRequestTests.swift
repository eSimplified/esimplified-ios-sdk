//
//  RegisterCustomerRequestTests.swift
//  EsimplifiedSDK
//

import Testing
import Foundation
@testable import EsimplifiedSDK

@Suite("RegisterCustomerRequest encoding")
struct RegisterCustomerRequestTests {

    private func encode(_ request: RegisterCustomerRequest) throws -> [String: Any] {
        let data = try JSONEncoder().encode(request)
        return try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
    }

    @Test("marketing_opt_in is omitted when nil")
    func marketingOptInOmittedWhenNil() throws {
        let request = RegisterCustomerRequest(
            firstName: "A", lastName: "B", email: "a@b.com",
            mobileNumber: "+1234", referredBy: nil, password: "secret",
            marketingOptIn: nil
        )
        let json = try encode(request)
        #expect(json["marketing_opt_in"] == nil)
    }

    @Test("marketing_opt_in is included when true")
    func marketingOptInIncludedWhenTrue() throws {
        let request = RegisterCustomerRequest(
            firstName: "A", lastName: "B", email: "a@b.com",
            mobileNumber: "+1234", referredBy: nil, password: "secret",
            marketingOptIn: true
        )
        let json = try encode(request)
        #expect(json["marketing_opt_in"] as? Bool == true)
    }

    @Test("marketing_opt_in is included when false")
    func marketingOptInIncludedWhenFalse() throws {
        let request = RegisterCustomerRequest(
            firstName: "A", lastName: "B", email: "a@b.com",
            mobileNumber: "+1234", referredBy: nil, password: "secret",
            marketingOptIn: false
        )
        let json = try encode(request)
        #expect(json["marketing_opt_in"] as? Bool == false)
    }
}
