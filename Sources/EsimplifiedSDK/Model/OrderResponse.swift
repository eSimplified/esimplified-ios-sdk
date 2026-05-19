//
//  OrderResponse.swift
//  KnowRoaming
//
//  Created by Kieran on 2025/03/06.
//

import Foundation

// MARK: Orders Response

public struct OrdersResponse: Codable {
    public let count: Int
    public let next: String?
    public let previous: String?
    public let orders: [Order]

    public init(count: Int, next: String? = nil, previous: String? = nil, orders: [Order]) {
        self.count = count
        self.next = next
        self.previous = previous
        self.orders = orders
    }

    enum CodingKeys: String, CodingKey {
        case count, next, previous
        case orders = "results"
    }
}

// MARK: Order Model

public struct Order: Codable, Identifiable {
    public var id: String { orderUUID }
    public let user: String
    public let esim: EsimInfo
    public let orderNumber: Int
    public let orderUUID: String
    public let orderType: String
    public let packageID: String
    public let finalPrice: String
    public let conversionTracked: Bool
    public let packageName: String
    public let purchaseDate: String
    public let purchasePrice: String
    public let discountCode: String
    public let discountAmount: String
    public let purchaseCurrency: String
    public let purchaseCurrencyObject: Currency
    public let paymentMethod: PaymentMethod
    public let purchaseCountry: PurchaseCountry?
    public let packageTypeID: Int
    public let paymentStatus: String
    public let country: Country
    public let loyaltyPointsEarned: LoyaltyPointsDetail?
    public let loyaltyPointsSpent: LoyaltyPointsDetail?

    public var transactionType: TransactionType {
        orderType == "TOP UP" ? .topUp : .buy
    }

    enum CodingKeys: String, CodingKey {
        case user, country, esim
        case orderNumber = "order_number"
        case orderUUID = "order_uuid"
        case orderType = "order_type"
        case packageID = "package_id"
        case finalPrice = "final_price"
        case conversionTracked = "conversion_tracked"
        case packageName = "package_name"
        case purchaseDate = "purchase_date"
        case purchasePrice = "purchase_price"
        case discountCode = "discount_code"
        case discountAmount = "discount_amount"
        case purchaseCurrency = "purchase_currency"
        case paymentMethod = "payment_method"
        case purchaseCountry = "purchase_country"
        case packageTypeID = "package_type_id"
        case paymentStatus = "payment_status"
        case purchaseCurrencyObject = "purchase_currency_obj"
        case loyaltyPointsEarned = "points_earned"
        case loyaltyPointsSpent = "points_spent"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        user = try container.decode(String.self, forKey: .user)
        esim = try container.decode(EsimInfo.self, forKey: .esim)
        orderNumber = try container.decode(Int.self, forKey: .orderNumber)
        orderUUID = try container.decode(String.self, forKey: .orderUUID)
        orderType = try container.decode(String.self, forKey: .orderType)
        packageID = try container.decode(String.self, forKey: .packageID)
        finalPrice = try container.decode(String.self, forKey: .finalPrice)
        conversionTracked = try container.decode(Bool.self, forKey: .conversionTracked)
        packageName = try container.decode(String.self, forKey: .packageName)
        purchaseDate = try container.decode(String.self, forKey: .purchaseDate)
        purchasePrice = try container.decode(String.self, forKey: .purchasePrice)
        discountCode = try container.decode(String.self, forKey: .discountCode)
        discountAmount = try container.decode(String.self, forKey: .discountAmount)
        purchaseCurrency = try container.decode(String.self, forKey: .purchaseCurrency)
        purchaseCurrencyObject = try container.decode(Currency.self, forKey: .purchaseCurrencyObject)
        paymentMethod = try container.decode(PaymentMethod.self, forKey: .paymentMethod)
        purchaseCountry = try container.decodeIfPresent(PurchaseCountry.self, forKey: .purchaseCountry)
        packageTypeID = try container.decode(Int.self, forKey: .packageTypeID)
        paymentStatus = try container.decode(String.self, forKey: .paymentStatus)
        country = try container.decode(Country.self, forKey: .country)
        loyaltyPointsEarned = try container.decodeIfPresent(LoyaltyPointsDetail.self, forKey: .loyaltyPointsEarned)
        loyaltyPointsSpent = try container.decodeIfPresent(LoyaltyPointsDetail.self, forKey: .loyaltyPointsSpent)
    }
}

// MARK: Esim Info Model

public struct EsimInfo: Codable {
    public let iccid: String
    public let country: String
    public let matchingID: String
    public let androidSha: Bool
    public let smDpAddress: String
    public let assignedDate: String
    public let premium: Bool

    public init(iccid: String, country: String, matchingID: String, androidSha: Bool, smDpAddress: String, assignedDate: String, premium: Bool) {
        self.iccid = iccid
        self.country = country
        self.matchingID = matchingID
        self.androidSha = androidSha
        self.smDpAddress = smDpAddress
        self.assignedDate = assignedDate
        self.premium = premium
    }

    enum CodingKeys: String, CodingKey {
        case iccid, country, premium
        case matchingID = "matching_id"
        case androidSha = "android_sha"
        case smDpAddress = "sm_dp_address"
        case assignedDate = "assigned_date"
    }
}

// MARK: Purchase Country Model

public struct PurchaseCountry: Codable {
    public let iso: String
    public let name: String
    public let iso3: String
    public let flag: String
    public let isRegion: Bool

    public init(iso: String, name: String, iso3: String, flag: String, isRegion: Bool) {
        self.iso = iso
        self.name = name
        self.iso3 = iso3
        self.flag = flag
        self.isRegion = isRegion
    }

    enum CodingKeys: String, CodingKey {
        case iso, name, iso3, flag
        case isRegion = "is_region"
    }
}

// MARK: Payment Method Enum

public enum PaymentMethod: String, Codable {
    case stripeIntent = "stripe_intent"
    case stripeCheckout = "stripe_checkout"
    case agentPayment = "agent_payment"
    case complimentary = "complimentary"
    case voucher = "voucher"
    case splitPayment = "split_payment"
    case paidWithPoints = "pay_with_points"
    case unknown

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = PaymentMethod(rawValue: rawValue) ?? .unknown
    }

    public var displayName: String {
        switch self {
        case .stripeIntent:
            return "Stripe"
        case .stripeCheckout:
            return "Stripe Checkout"
        case .agentPayment:
            return "Agent Payment"
        case .complimentary:
            return "Complimentary"
        case .voucher:
            return "Voucher"
        case .splitPayment:
            return "Split Payment"
        case .paidWithPoints:
            return "Pay with Points"
        case .unknown:
            return "Payment"
        }
    }

    public var shouldShowAmount: Bool {
        switch self {
        case .stripeIntent, .stripeCheckout, .agentPayment, .splitPayment, .paidWithPoints:
            return true
        case .complimentary, .voucher, .unknown:
            return false
        }
    }
}
