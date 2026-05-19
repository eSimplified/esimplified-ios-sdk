//
//  PaymentResponse.swift
//  KnowRoaming
//
//  Created by Kieran on 2025/03/06.
//

import Foundation

// MARK: Payment Response

public struct PaymentResponse: Codable {
    public let detail: String
    public let paymentData: PaymentData

    public init(detail: String, paymentData: PaymentData) {
        self.detail = detail
        self.paymentData = paymentData
    }

    enum CodingKeys: String, CodingKey {
        case detail
        case paymentData = "data"
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

    public init(uri: String? = nil, orderID: String? = nil, isIntent: Bool? = nil, customerRef: String? = nil, ephemeralKey: String? = nil, publishableKey: String? = nil, zeroCharge: Bool? = nil) {
        self.uri = uri
        self.orderID = orderID
        self.isIntent = isIntent
        self.customerRef = customerRef
        self.ephemeralKey = ephemeralKey
        self.publishableKey = publishableKey
        self.zeroCharge = zeroCharge
    }

    enum CodingKeys: String, CodingKey {
        case uri
        case orderID = "order_id"
        case isIntent = "is_intent"
        case customerRef = "customer_ref"
        case ephemeralKey = "ephemeral_key"
        case publishableKey = "publishable_key"
        case zeroCharge = "zero_charge"
    }
}

// MARK: Payment Request

public struct PaymentRequest: Encodable {
    public var type: TransactionType
    public var payment_method: PaymentMethod = .stripeIntent
    public var package_type_id: String
    public var iccid: String?
    public var coupon_id: String?
    public var customer: CustomerEmail
    public var auto_top_up: Bool?
    public var save_payment_method: Bool?
    public var loyalty_points_amount: Double?

    public init(type: TransactionType, payment_method: PaymentMethod = .stripeIntent, package_type_id: String, iccid: String? = nil, coupon_id: String? = nil, customer: CustomerEmail, auto_top_up: Bool? = nil, save_payment_method: Bool? = nil, loyalty_points_amount: Double? = nil) {
        self.type = type
        self.payment_method = payment_method
        self.package_type_id = package_type_id
        self.iccid = iccid
        self.coupon_id = coupon_id
        self.customer = customer
        self.auto_top_up = auto_top_up
        self.save_payment_method = save_payment_method
        self.loyalty_points_amount = loyalty_points_amount
    }
}

// MARK: Kreds Quote Request

public struct KredsQuoteRequest: Encodable {
    public let package_type_id: Int
    public let loyalty_points_amount: Double

    public init(package_type_id: Int, loyalty_points_amount: Double) {
        self.package_type_id = package_type_id
        self.loyalty_points_amount = loyalty_points_amount
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

    public init(packageTypeID: Int? = nil, currency: Currency? = nil, preferredCurrency: Currency? = nil, pricing: KredsQuotePricing, points: KredsQuotePoints, notices: [KredsQuoteNotice]? = nil) {
        self.packageTypeID = packageTypeID
        self.currency = currency
        self.preferredCurrency = preferredCurrency
        self.pricing = pricing
        self.points = points
        self.notices = notices
    }

    enum CodingKeys: String, CodingKey {
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

    public init(orderCurrency: KredsQuoteOrderCurrency, usd: KredsQuoteUsdPricing, preferredCurrency: KredsQuotePreferredPricing) {
        self.orderCurrency = orderCurrency
        self.usd = usd
        self.preferredCurrency = preferredCurrency
    }

    enum CodingKeys: String, CodingKey {
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

    public init(exchangeRateToUsd: String? = nil, subtotal: String? = nil, packageDiscount: String? = nil, promoDiscount: String? = nil, pointsApplied: String? = nil, total: String, currency: Currency? = nil) {
        self.exchangeRateToUsd = exchangeRateToUsd
        self.subtotal = subtotal
        self.packageDiscount = packageDiscount
        self.promoDiscount = promoDiscount
        self.pointsApplied = pointsApplied
        self.total = total
        self.currency = currency
    }

    enum CodingKeys: String, CodingKey {
        case currency
        case exchangeRateToUsd = "exchange_rate_to_usd"
        case subtotal = "subtotal"
        case packageDiscount = "package_discount"
        case promoDiscount = "promo_discount"
        case pointsApplied = "points_applied"
        case total = "total"
    }
}

public struct KredsQuoteUsdPricing: Codable {
    public let subtotal: String?
    public let packageDiscount: String?
    public let promoDiscount: String?
    public let pointsApplied: String?
    public let total: String
    public let currency: Currency

    public init(subtotal: String? = nil, packageDiscount: String? = nil, promoDiscount: String? = nil, pointsApplied: String? = nil, total: String, currency: Currency) {
        self.subtotal = subtotal
        self.packageDiscount = packageDiscount
        self.promoDiscount = promoDiscount
        self.pointsApplied = pointsApplied
        self.total = total
        self.currency = currency
    }

    enum CodingKeys: String, CodingKey {
        case currency
        case subtotal = "subtotal"
        case packageDiscount = "package_discount"
        case promoDiscount = "promo_discount"
        case pointsApplied = "points_applied"
        case total = "total"
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

    public init(requestedCents: Int? = nil, appliedCents: Int? = nil, appliedValue: KredsQuoteValue? = nil, appliedValueUsd: KredsQuoteValue? = nil, appliedValuePreferred: KredsQuoteValue? = nil) {
        self.requestedCents = requestedCents
        self.appliedCents = appliedCents
        self.appliedValue = appliedValue
        self.appliedValueUsd = appliedValueUsd
        self.appliedValuePreferred = appliedValuePreferred
    }

    enum CodingKeys: String, CodingKey {
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
