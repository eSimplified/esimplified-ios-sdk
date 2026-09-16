//
//  OrderDetailDecodingTests.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/09/16.
//

import Testing
import Foundation
@testable import EsimplifiedSDK

@Suite("OrderDetail Decoding")
struct OrderDetailDecodingTests {

    /// A pending order, exactly as the API returns one before the eSIM is provisioned:
    /// no qr_code, sm_dp_address, activation_code, country_name, country_code or profile.
    private let pendingOrderJSON = """
    {
      "order_status": "pending",
      "order_type": "BUY",
      "order_number": 8084,
      "order_date": "2026-09-16T11:23:46.539953Z",
      "customer_id": "2ebfb68c-c36f-41a3-a5c1-052420dad0d2",
      "transaction_id": null,
      "password_reset_encoded": null,
      "conversion_tracked": false,
      "payment_method": "stripe_intent",
      "purchase_price": "139.00",
      "purchase_currency": "R",
      "purchase_currency_obj": { "iso": "ZAR", "symbol": "R" },
      "final_price": "139.00",
      "discount_amount": "0.00",
      "discount_code": "",
      "qr_code_image_base64": "",
      "package_name": "South Africa 3 GB 10 Days - Real eSIM",
      "package_type_id": 656842,
      "package_data_size": 3,
      "package_validity": 10,
      "country": {
        "country_name": "South Africa",
        "country_name_slug": "south-africa",
        "country_code": "ZA",
        "country_flag": "\u{1F1FF}\u{1F1E6}",
        "country_flag_css": "flag-sprite flag-z flag-_a",
        "is_region": false
      },
      "package": {
        "name": "South Africa 3 GB 10 Days - Real eSIM",
        "price": "7.50",
        "converted_price": 139,
        "data_GB": "3.00",
        "currency": "R",
        "currency_obj": { "iso": "ZAR", "symbol": "R" },
        "package_type_id": 656842,
        "validity_days": 10,
        "validity_days_display": "10 Days",
        "package_slug": "3-gb-10-days-real-esim",
        "plan_type": "Data Only",
        "kyc_display": "No KYC required",
        "best_connectivity": "LTE",
        "activation_policy": "The validity period starts when the eSIM connects to any supported network(s).",
        "supported_countries": [""],
        "discount_label": "",
        "discount_percentage": "0.00",
        "discounted_price": 139,
        "earn_percentage": 3,
        "esim_provider": "IMPERIUM",
        "name_additional_text": "Real eSIM",
        "network": ["Vodacom (Pty) Ltd."],
        "complimentary_package": null,
        "country": "ZA"
      }
    }
    """

    @Test("A pending order decodes even though the eSIM fields are absent")
    func pendingOrderDecodes() throws {
        let order = try JSONDecoder().decode(OrderDetail.self, from: Data(pendingOrderJSON.utf8))

        #expect(order.orderStatus == "pending")
        #expect(order.orderNumber == 8084)
        #expect(order.qrCode == nil)
        #expect(order.smDpAddress == nil)
        #expect(order.activationCode == nil)
        #expect(order.countryName == nil)
        #expect(order.countryCode == nil)
        #expect(order.profile == nil)
        #expect(order.country?.countryName == "South Africa")
    }

    @Test("A decoding failure names the missing key for the log, but not for the customer")
    func decodingFailureNamesTheKey() {
        let missingOrderNumber = pendingOrderJSON.replacingOccurrences(
            of: "\"order_number\": 8084,",
            with: ""
        )

        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(OrderDetail.self, from: Data(missingOrderNumber.utf8))
        }

        do {
            _ = try JSONDecoder().decode(OrderDetail.self, from: Data(missingOrderNumber.utf8))
        } catch {
            #expect(SdkError.decodingError(error).debugDescription.contains("order_number"))
            #expect(SdkError.decodingError(error).errorDescription?.contains("order_number") == false)
        }
    }
}
