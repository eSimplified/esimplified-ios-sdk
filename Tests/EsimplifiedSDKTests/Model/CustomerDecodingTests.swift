//
//  CustomerDecodingTests.swift
//  EsimplifiedSDKTests
//  Created by Kieran on 2026/09/22.
//

import Foundation
import Testing
@testable import EsimplifiedSDK

@Suite("Customer Decoding")
struct CustomerDecodingTests {

    private func decode(_ json: String) throws -> User {
        try JSONDecoder().decode(User.self, from: Data(json.utf8))
    }

    private let customerPayload = """
    {
      "email": "kieran@esimplified.io",
      "phone_number": "+27724042682",
      "phone_verified": false,
      "first_name": "Kieran",
      "last_name": "Woodrow",
      "full_name": "Kieran Woodrow",
      "customer_id": "3b25c651-6097-47f6-ab00-1df2cfb32715",
      "referral_code": "REFM1RSGX0NKRST",
      "external_reference": null,
      "preferred_language": "en",
      "preferred_currency": "USD",
      "loyalty_provider": "kreds",
      "receive_marketing_email": true,
      "receive_marketing_push": true,
      "receive_account_email": true,
      "receive_account_sms": true,
      "receive_account_push": true,
      "receive_purchase_email": true,
      "receive_purchase_push": true,
      "receive_viber_messages": false,
      "signed_in_with_provider": true
    }
    """

    @Test("Every field the customer endpoint returns decodes")
    func decodesTheCustomerPayload() throws {
        let user = try decode(customerPayload)

        #expect(user.email == "kieran@esimplified.io")
        #expect(user.phoneNumber == "+27724042682")
        #expect(user.phoneVerified == false)
        #expect(user.firstName == "Kieran")
        #expect(user.lastName == "Woodrow")
        #expect(user.fullName == "Kieran Woodrow")
        #expect(user.customerId == "3b25c651-6097-47f6-ab00-1df2cfb32715")
        #expect(user.referralCode == "REFM1RSGX0NKRST")
        #expect(user.externalReference == nil)
        #expect(user.preferredLanguage == "en")
        #expect(user.preferredCurrency == "USD")
        #expect(user.loyaltyProvider == .kreds)
        #expect(user.receiveMarketingEmail == true)
        #expect(user.receiveMarketingPush == true)
        #expect(user.receiveAccountEmail == true)
        #expect(user.receiveAccountSms == true)
        #expect(user.receiveAccountPush == true)
        #expect(user.receivePurchaseEmail == true)
        #expect(user.receivePurchasePush == true)
        #expect(user.receiveViberMessages == false)
        #expect(user.signedInWithProvider == true)
    }

    @Test("A loyalty provider the app does not know about decodes as none")
    func decodesAnUnknownLoyaltyProvider() throws {
        let user = try decode("""
        {"email":"a@b.com","loyalty_provider":"somethingNew"}
        """)

        #expect(user.loyaltyProvider == nil)
        #expect(user.email == "a@b.com")
    }

    @Test("A customer with no loyalty programme decodes as none")
    func decodesAMissingLoyaltyProvider() throws {
        let user = try decode("""
        {"email":"a@b.com"}
        """)

        #expect(user.loyaltyProvider == nil)
    }

    @Test(
        "The loyalty providers the backend can send map to their cases",
        arguments: [("kreds", LoyaltyProvider.kreds), ("mokafaa", .mokafaa)]
    )
    func decodesEachLoyaltyProvider(raw: String, expected: LoyaltyProvider) throws {
        let user = try decode("""
        {"email":"a@b.com","loyalty_provider":"\(raw)"}
        """)

        #expect(user.loyaltyProvider == expected)
    }
}
