import Foundation

enum OrderDetailJSON {
    static func make(orderStatus: String = "success", paymentStatus: String? = "success", iccid: String? = "8901234567890123456") -> String {
        let iccidValue = iccid.map { "\"\($0)\"" } ?? "null"
        let paymentStatusLine = paymentStatus.map { "\"payment_status\": \"\($0)\"," } ?? ""
        return """
        {
            "iccid": \(iccidValue),
            "qr_code": "LPA:1$smdp.example.com$ACT-CODE-001",
            "sm_dp_address": "smdp.example.com",
            "activation_code": "ACT-CODE-001",
            "country_name": "United States",
            "country_code": "US",
            "country": {
                "country_name": "United States",
                "country_name_slug": "united-states",
                "country_code": "US",
                "country_flag": "flag-us",
                "country_flag_css": "us",
                "is_region": false,
                "from_price": "4.50",
                "currency": "USD",
                "currency_obj": { "symbol": "$", "iso": "USD" }
            },
            "order_number": 1001,
            "order_type": "BUY",
            "order_date": "2025-04-30T10:00:00.000000+0000",
            "order_status": "\(orderStatus)",
            \(paymentStatusLine)
            "purchase_price": "14.50",
            "transaction_id": "txn-abc-123",
            "purchase_currency": "USD",
            "purchase_currency_obj": { "symbol": "$", "iso": "USD" },
            "package_name": "5 GB - 30 Days",
            "package_type_id": 101,
            "package_data_size": 5.0,
            "package_validity": 30,
            "discount_amount": "0.00",
            "final_price": "14.50",
            "discount_code": "",
            "customer_id": "cust-001",
            "conversion_tracked": false,
            "password_reset_encoded": null,
            "payment_method": "stripe_intent",
            "package": {
                "name": "5 GB - 30 Days",
                "price": "14.50",
                "converted_price": 14.50,
                "data_GB": "5.00",
                "country": {
                    "country_name": "United States",
                    "country_name_slug": "united-states",
                    "country_code": "US",
                    "country_flag": "flag-us",
                    "country_flag_css": "us",
                    "is_region": false,
                    "from_price": "4.50",
                    "currency": "USD",
                    "currency_obj": { "symbol": "$", "iso": "USD" }
                },
                "network": ["T-Mobile"],
                "currency": "USD",
                "currency_obj": { "symbol": "$", "iso": "USD" },
                "plan_type": "data_only",
                "kyc_display": "none",
                "package_slug": "us-5gb-30days",
                "validity_days": 30,
                "validity_days_display": "30 Days",
                "package_type_id": 101,
                "best_connectivity": "5G",
                "activation_policy": "first-usage",
                "supported_countries": [
                    { "country_name": "United States", "country_code": "US" }
                ],
                "name_additional_text": "",
                "discount_label": "",
                "discount_percentage": null,
                "earn_percentage": 5.0,
                "promo_code": null,
                "data_cap": null,
                "throttle_speed": null
            },
            "qr_code_image_base64": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==",
            "profile": {
                "state": "RELEASED",
                "last_operation_date": 1714500000,
                "activation_code": "LPA:1$smdp.example.com$ACT-CODE-001",
                "reuse_remaining_count": 0,
                "reuse_enabled": false,
                "cc_required": false,
                "release_date": 1714400000,
                "state_message": "Profile is released",
                "last_operation_date_utc": "2025-04-30T20:00:00Z",
                "release_date_utc": "2025-04-30T10:00:00Z"
            },
            "points_earned": null,
            "points_spent": null
        }
        """
    }
}
