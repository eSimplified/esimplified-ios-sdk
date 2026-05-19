//
//  EsimOrderResponse.swift
//  KnowRoaming
//
//  Created by Kieran on 2025/03/23.
//

import Foundation

// MARK: Order Detail Model

public struct OrderDetail: Codable {
    public let iccid: String?
    public let qrCode: String
    public let smDpAddress: String
    public let activationCode: String
    public let countryName: String
    public let countryCode: String
    public let country: Country
    public let orderNumber: Int
    public let orderType: String
    public let orderDate: String
    public let orderStatus: String
    public let purchasePrice: String
    public let transactionId: String?
    public let purchaseCurrency: String
    public let purchaseCurrencyObject: Currency
    public let packageName: String
    public let packageTypeId: Int
    public let packageDataSize: Double
    public let packageValidity: Int
    public let discountAmount: String
    public let finalPrice: String
    public let discountCode: String
    public let customerId: String
    public let conversionTracked: Bool
    public let passwordResetEncoded: String?
    public let paymentMethod: PaymentMethod
    public let package: Package
    public let qrCodeImageBase64: String?
    public let profile: EsimProfile
    public let loyaltyPointsEarned: LoyaltyPointsDetail?
    public let loyaltyPointsSpent: LoyaltyPointsDetail?

    enum CodingKeys: String, CodingKey {
        case iccid, package, country, profile
        case qrCode = "qr_code"
        case smDpAddress = "sm_dp_address"
        case activationCode = "activation_code"
        case countryName = "country_name"
        case countryCode = "country_code"
        case orderNumber = "order_number"
        case orderType = "order_type"
        case orderDate = "order_date"
        case orderStatus = "order_status"
        case purchasePrice = "purchase_price"
        case transactionId = "transaction_id"
        case purchaseCurrency = "purchase_currency"
        case packageName = "package_name"
        case packageTypeId = "package_type_id"
        case packageDataSize = "package_data_size"
        case packageValidity = "package_validity"
        case discountAmount = "discount_amount"
        case finalPrice = "final_price"
        case discountCode = "discount_code"
        case customerId = "customer_id"
        case conversionTracked = "conversion_tracked"
        case passwordResetEncoded = "password_reset_encoded"
        case paymentMethod = "payment_method"
        case qrCodeImageBase64 = "qr_code_image_base64"
        case purchaseCurrencyObject = "purchase_currency_obj"
        case loyaltyPointsEarned = "points_earned"
        case loyaltyPointsSpent = "points_spent"
    }

    public init(
        iccid: String? = nil,
        qrCode: String,
        smDpAddress: String,
        activationCode: String,
        countryName: String,
        countryCode: String,
        country: Country,
        orderNumber: Int,
        orderType: String,
        orderDate: String,
        orderStatus: String,
        purchasePrice: String,
        transactionId: String? = nil,
        purchaseCurrency: String,
        purchaseCurrencyObject: Currency,
        packageName: String,
        packageTypeId: Int,
        packageDataSize: Double,
        packageValidity: Int,
        discountAmount: String,
        finalPrice: String,
        discountCode: String,
        customerId: String,
        conversionTracked: Bool,
        passwordResetEncoded: String? = nil,
        paymentMethod: PaymentMethod,
        package: Package,
        qrCodeImageBase64: String? = nil,
        profile: EsimProfile,
        loyaltyPointsEarned: LoyaltyPointsDetail? = nil,
        loyaltyPointsSpent: LoyaltyPointsDetail? = nil
    ) {
        self.iccid = iccid
        self.qrCode = qrCode
        self.smDpAddress = smDpAddress
        self.activationCode = activationCode
        self.countryName = countryName
        self.countryCode = countryCode
        self.country = country
        self.orderNumber = orderNumber
        self.orderType = orderType
        self.orderDate = orderDate
        self.orderStatus = orderStatus
        self.purchasePrice = purchasePrice
        self.transactionId = transactionId
        self.purchaseCurrency = purchaseCurrency
        self.purchaseCurrencyObject = purchaseCurrencyObject
        self.packageName = packageName
        self.packageTypeId = packageTypeId
        self.packageDataSize = packageDataSize
        self.packageValidity = packageValidity
        self.discountAmount = discountAmount
        self.finalPrice = finalPrice
        self.discountCode = discountCode
        self.customerId = customerId
        self.conversionTracked = conversionTracked
        self.passwordResetEncoded = passwordResetEncoded
        self.paymentMethod = paymentMethod
        self.package = package
        self.qrCodeImageBase64 = qrCodeImageBase64
        self.profile = profile
        self.loyaltyPointsEarned = loyaltyPointsEarned
        self.loyaltyPointsSpent = loyaltyPointsSpent
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        iccid = try container.decodeIfPresent(String.self, forKey: .iccid)
        qrCode = try container.decode(String.self, forKey: .qrCode)
        smDpAddress = try container.decode(String.self, forKey: .smDpAddress)
        activationCode = try container.decode(String.self, forKey: .activationCode)
        countryName = try container.decode(String.self, forKey: .countryName)
        countryCode = try container.decode(String.self, forKey: .countryCode)
        country = try container.decode(Country.self, forKey: .country)
        orderNumber = try container.decode(Int.self, forKey: .orderNumber)
        orderType = try container.decode(String.self, forKey: .orderType)
        orderDate = try container.decode(String.self, forKey: .orderDate)
        orderStatus = try container.decode(String.self, forKey: .orderStatus)
        purchasePrice = try container.decode(String.self, forKey: .purchasePrice)
        transactionId = try container.decodeIfPresent(String.self, forKey: .transactionId)
        purchaseCurrency = try container.decode(String.self, forKey: .purchaseCurrency)
        purchaseCurrencyObject = try container.decode(Currency.self, forKey: .purchaseCurrencyObject)
        packageName = try container.decode(String.self, forKey: .packageName)
        packageTypeId = try container.decode(Int.self, forKey: .packageTypeId)
        packageDataSize = try container.decode(Double.self, forKey: .packageDataSize)
        packageValidity = try container.decode(Int.self, forKey: .packageValidity)
        discountAmount = try container.decode(String.self, forKey: .discountAmount)
        finalPrice = try container.decode(String.self, forKey: .finalPrice)
        discountCode = try container.decode(String.self, forKey: .discountCode)
        customerId = try container.decode(String.self, forKey: .customerId)
        conversionTracked = try container.decode(Bool.self, forKey: .conversionTracked)
        passwordResetEncoded = try container.decodeIfPresent(String.self, forKey: .passwordResetEncoded)
        paymentMethod = try container.decode(PaymentMethod.self, forKey: .paymentMethod)
        package = try container.decode(Package.self, forKey: .package)
        qrCodeImageBase64 = try container.decodeIfPresent(String.self, forKey: .qrCodeImageBase64)
        profile = try container.decode(EsimProfile.self, forKey: .profile)
        loyaltyPointsEarned = try container.decodeIfPresent(LoyaltyPointsDetail.self, forKey: .loyaltyPointsEarned)
        loyaltyPointsSpent = try container.decodeIfPresent(LoyaltyPointsDetail.self, forKey: .loyaltyPointsSpent)
    }

    public var orderTypeEnum: EsimOrderState {
        EsimOrderState(rawValue: orderType) ?? .buy
    }

    public var packagePurchaseDate: Date? {
        guard !orderDate.isEmpty else { return nil }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        return formatter.date(from: orderDate)
    }

    public var packageExpiryDate: Date? {
        guard let packagePurchaseDate else { return nil }
        return Calendar.current.date(byAdding: .day, value: self.packageValidity, to: packagePurchaseDate)
    }
}

// MARK: Esim Order State Enum

public enum EsimOrderState: String {
    case buy = "BUY"
    case topUP = "TOP UP"
    case autoTopUp = "AUTO TOP UP"
    case complimentary = "Complimentary"
}
