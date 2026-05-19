//
//  PaymentResponse.swift
//  EsimplifiedSDK
//

import Foundation

// MARK: Payment Response

public struct PaymentResponse: Codable {
    public let detail: String
    public let paymentData: PaymentData

    public enum CodingKeys: String, CodingKey {
        case detail
        case paymentData = "data"
    }

    public init(detail: String, paymentData: PaymentData) {
        self.detail = detail
        self.paymentData = paymentData
    }
}

// MARK: Payment Data Model

public struct PaymentData: Codable {
    public let uri: String?
    public let orderID: String?
    public let isIntent: Bool?
    public let customerRef: String?
    public let ephemeralKey: String?
    public let publishableKey: String?
    public let zeroCharge: Bool?

    public enum CodingKeys: String, CodingKey {
        case uri
        case orderID = "order_id"
        case isIntent = "is_intent"
        case customerRef = "customer_ref"
        case ephemeralKey = "ephemeral_key"
        case publishableKey = "publishable_key"
        case zeroCharge = "zero_charge"
    }

    public init(uri: String? = nil, orderID: String? = nil, isIntent: Bool? = nil,
                customerRef: String? = nil, ephemeralKey: String? = nil,
                publishableKey: String? = nil, zeroCharge: Bool? = nil) {
        self.uri = uri
        self.orderID = orderID
        self.isIntent = isIntent
        self.customerRef = customerRef
        self.ephemeralKey = ephemeralKey
        self.publishableKey = publishableKey
        self.zeroCharge = zeroCharge
    }
}

// MARK: Payment Request

public struct PaymentRequest: Encodable {
    public var type: TransactionType
    public var paymentMethod: PaymentMethod = .stripeIntent
    public var packageTypeId: String
    public var iccid: String?
    public var couponId: String?
    public var customer: CustomerEmail
    public var autoTopUp: Bool?
    public var savePaymentMethod: Bool?
    public var loyaltyPointsAmount: Double?

    public enum CodingKeys: String, CodingKey {
        case type
        case paymentMethod = "payment_method"
        case packageTypeId = "package_type_id"
        case iccid
        case couponId = "coupon_id"
        case customer
        case autoTopUp = "auto_top_up"
        case savePaymentMethod = "save_payment_method"
        case loyaltyPointsAmount = "loyalty_points_amount"
    }

    public init(type: TransactionType, paymentMethod: PaymentMethod = .stripeIntent,
                packageTypeId: String, iccid: String? = nil, couponId: String? = nil,
                customer: CustomerEmail, autoTopUp: Bool? = nil,
                savePaymentMethod: Bool? = nil, loyaltyPointsAmount: Double? = nil) {
        self.type = type
        self.paymentMethod = paymentMethod
        self.packageTypeId = packageTypeId
        self.iccid = iccid
        self.couponId = couponId
        self.customer = customer
        self.autoTopUp = autoTopUp
        self.savePaymentMethod = savePaymentMethod
        self.loyaltyPointsAmount = loyaltyPointsAmount
    }
}

// MARK: Kreds Quote Request

public struct KredsQuoteRequest: Encodable {
    public let packageTypeId: Int
    public let loyaltyPointsAmount: Double

    public enum CodingKeys: String, CodingKey {
        case packageTypeId = "package_type_id"
        case loyaltyPointsAmount = "loyalty_points_amount"
    }

    public init(packageTypeId: Int, loyaltyPointsAmount: Double) {
        self.packageTypeId = packageTypeId
        self.loyaltyPointsAmount = loyaltyPointsAmount
    }
}

// MARK: Kreds Quote Response

public struct KredsQuoteResponse: Codable {
    public let packageTypeID: Int?
    public let currency: Currency?
    public let preferredCurrency: Currency?
    public let pricing: KredsQuotePricing
    public let points: KredsQuotePoints
    public let notices: [KredsQuoteNotice]?

    public enum CodingKeys: String, CodingKey {
        case currency, pricing, points, notices
        case packageTypeID = "package_type_id"
        case preferredCurrency = "preferred_currency"
    }
}

public struct KredsQuoteNotice: Codable {
    public let code: String
    public let message: String

    public init(code: String, message: String) {
        self.code = code
        self.message = message
    }
}

public struct KredsQuotePricing: Codable {
    public let orderCurrency: KredsQuoteOrderCurrency
    public let usd: KredsQuoteUsdPricing
    public let preferredCurrency: KredsQuotePreferredPricing

    public enum CodingKeys: String, CodingKey {
        case usd
        case orderCurrency = "order_currency"
        case preferredCurrency = "preferred_currency"
    }
}

public struct KredsQuoteOrderCurrency: Codable {
    public let exchangeRateToUsd: String?
    public let subtotal: String?
    public let packageDiscount: String?
    public let promoDiscount: String?
    public let pointsApplied: String?
    public let total: String
    public let currency: Currency?

    public enum CodingKeys: String, CodingKey {
        case currency
        case exchangeRateToUsd = "exchange_rate_to_usd"
        case subtotal
        case packageDiscount = "package_discount"
        case promoDiscount = "promo_discount"
        case pointsApplied = "points_applied"
        case total
    }
}

public struct KredsQuoteUsdPricing: Codable {
    public let subtotal: String?
    public let packageDiscount: String?
    public let promoDiscount: String?
    public let pointsApplied: String?
    public let total: String
    public let currency: Currency

    public enum CodingKeys: String, CodingKey {
        case currency
        case subtotal
        case packageDiscount = "package_discount"
        case promoDiscount = "promo_discount"
        case pointsApplied = "points_applied"
        case total
    }
}

public struct KredsQuotePreferredPricing: Codable {
    public let total: String
    public let currency: Currency

    public init(total: String, currency: Currency) {
        self.total = total
        self.currency = currency
    }
}

public struct KredsQuotePoints: Codable {
    public let requestedCents: Int?
    public let appliedCents: Int?
    public let appliedValue: KredsQuoteValue?
    public let appliedValueUsd: KredsQuoteValue?
    public let appliedValuePreferred: KredsQuoteValue?

    public enum CodingKeys: String, CodingKey {
        case requestedCents = "requested_cents"
        case appliedCents = "applied_cents"
        case appliedValue = "applied_value"
        case appliedValueUsd = "applied_value_usd"
        case appliedValuePreferred = "applied_value_preferred"
    }
}

public struct KredsQuoteValue: Codable {
    public let amount: String
    public let currency: Currency

    public init(amount: String, currency: Currency) {
        self.amount = amount
        self.currency = currency
    }
}
