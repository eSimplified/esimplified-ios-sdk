import Foundation

enum PendingOrderJSON {
    static func make(orderStatus: String = "pending", paymentStatus: String? = nil) -> String {
        let paymentStatusLine = paymentStatus.map { "\n  \"payment_status\": \"\($0)\"," } ?? ""
        return """
        {
          "order_status": "\(orderStatus)",\(paymentStatusLine)
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
    }
}
