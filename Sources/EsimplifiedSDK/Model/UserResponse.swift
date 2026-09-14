//
//  UserResponse.swift
//  KnowRoaming
//
//  Created by Kieran on 2025/02/17.
//

import Foundation

// MARK: Loyalty Provider

public enum LoyaltyProvider: String, Codable {
    case kreds
    case mokafaa
}

// MARK: Mokafaa Enrollment

public enum MokafaaEnrollmentState: String, Codable {
    case completed
    case pending
    case expired
    case elected
    case notElected = "not_elected"
}

public struct MokafaaEnrollment: Codable, Equatable {
    public let state: MokafaaEnrollmentState
    public let sessionExpiresAt: String?

    enum CodingKeys: String, CodingKey {
        case state
        case sessionExpiresAt = "session_expires_at"
    }

    public init(state: MokafaaEnrollmentState, sessionExpiresAt: String? = nil) {
        self.state = state
        self.sessionExpiresAt = sessionExpiresAt
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rawState = try container.decode(String.self, forKey: .state)
        state = MokafaaEnrollmentState(rawValue: rawState) ?? .notElected
        sessionExpiresAt = try container.decodeIfPresent(String.self, forKey: .sessionExpiresAt)
    }
}

// MARK: User Response

public struct User: Codable, Equatable {
    public var email: String? = ""
    public var phoneNumber: String? = ""
    public var firstName: String? = ""
    public var lastName: String? = ""
    public var fullName: String? = ""
    public var referralCode: String? = ""
    public var externalReference: String? = ""
    public var acquisitionSource: String?
    public var customerId: String? = ""
    public var receiveMarketingEmail: Bool?
    public var receiveMarketingPush: Bool?
    public var receiveAccountEmail: Bool?
    public var receiveAccountSms: Bool?
    public var receiveAccountPush: Bool?
    public var receivePurchaseEmail: Bool?
    public var receivePurchasePush: Bool?
    public var receiveViberMessages: Bool?
    public var preferredLanguage: String?
    public var preferredCurrency: String?
    public var signedInWithProvider: Bool?
    public var loyaltyProvider: LoyaltyProvider?
    public var mokafaaEnrollment: MokafaaEnrollment?

    enum CodingKeys: String, CodingKey {
        case email
        case phoneNumber = "phone_number"
        case firstName = "first_name"
        case lastName = "last_name"
        case fullName = "full_name"
        case referralCode = "referral_code"
        case uniqueReferralCode = "unique_referral_code"
        case externalReference = "external_reference"
        case acquisitionSource = "acquisition_source"
        case customerId = "customer_id"
        case receiveMarketingEmail = "receive_marketing_email"
        case receiveMarketingPush = "receive_marketing_push"
        case receiveAccountEmail = "receive_account_email"
        case receiveAccountSms = "receive_account_sms"
        case receiveAccountPush = "receive_account_push"
        case receivePurchaseEmail = "receive_purchase_email"
        case receivePurchasePush = "receive_purchase_push"
        case receiveViberMessages = "receive_viber_messages"
        case preferredLanguage = "preferred_language"
        case preferredCurrency = "preferred_currency"
        case signedInWithProvider = "signed_in_with_provider"
        case loyaltyProvider = "loyalty_provider"
        case mokafaaEnrollment = "mokafaa_enrollment"
    }

    public init(
        email: String? = "",
        phoneNumber: String? = "",
        firstName: String? = "",
        lastName: String? = "",
        fullName: String? = "",
        referralCode: String? = "",
        externalReference: String? = "",
        acquisitionSource: String? = nil,
        customerId: String? = "",
        receiveMarketingEmail: Bool? = nil,
        receiveMarketingPush: Bool? = nil,
        receiveAccountEmail: Bool? = nil,
        receiveAccountSms: Bool? = nil,
        receiveAccountPush: Bool? = nil,
        receivePurchaseEmail: Bool? = nil,
        receivePurchasePush: Bool? = nil,
        receiveViberMessages: Bool? = nil,
        preferredLanguage: String? = nil,
        preferredCurrency: String? = nil,
        signedInWithProvider: Bool? = nil,
        loyaltyProvider: LoyaltyProvider? = nil,
        mokafaaEnrollment: MokafaaEnrollment? = nil
    ) {
        self.email = email
        self.phoneNumber = phoneNumber
        self.firstName = firstName
        self.lastName = lastName
        self.fullName = fullName
        self.referralCode = referralCode
        self.externalReference = externalReference
        self.acquisitionSource = acquisitionSource
        self.customerId = customerId
        self.receiveMarketingEmail = receiveMarketingEmail
        self.receiveMarketingPush = receiveMarketingPush
        self.receiveAccountEmail = receiveAccountEmail
        self.receiveAccountSms = receiveAccountSms
        self.receiveAccountPush = receiveAccountPush
        self.receivePurchaseEmail = receivePurchaseEmail
        self.receivePurchasePush = receivePurchasePush
        self.receiveViberMessages = receiveViberMessages
        self.preferredLanguage = preferredLanguage
        self.preferredCurrency = preferredCurrency
        self.signedInWithProvider = signedInWithProvider
        self.loyaltyProvider = loyaltyProvider
        self.mokafaaEnrollment = mokafaaEnrollment
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        phoneNumber = try container.decodeIfPresent(String.self, forKey: .phoneNumber)
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        fullName = try container.decodeIfPresent(String.self, forKey: .fullName)
        referralCode = try container.decodeIfPresent(String.self, forKey: .referralCode)
            ?? container.decodeIfPresent(String.self, forKey: .uniqueReferralCode)
        externalReference = try container.decodeIfPresent(String.self, forKey: .externalReference)
        acquisitionSource = try container.decodeIfPresent(String.self, forKey: .acquisitionSource)
        customerId = try container.decodeIfPresent(String.self, forKey: .customerId)
        receiveMarketingEmail = try container.decodeIfPresent(Bool.self, forKey: .receiveMarketingEmail)
        receiveMarketingPush = try container.decodeIfPresent(Bool.self, forKey: .receiveMarketingPush)
        receiveAccountEmail = try container.decodeIfPresent(Bool.self, forKey: .receiveAccountEmail)
        receiveAccountSms = try container.decodeIfPresent(Bool.self, forKey: .receiveAccountSms)
        receiveAccountPush = try container.decodeIfPresent(Bool.self, forKey: .receiveAccountPush)
        receivePurchaseEmail = try container.decodeIfPresent(Bool.self, forKey: .receivePurchaseEmail)
        receivePurchasePush = try container.decodeIfPresent(Bool.self, forKey: .receivePurchasePush)
        receiveViberMessages = try container.decodeIfPresent(Bool.self, forKey: .receiveViberMessages)
        preferredLanguage = try container.decodeIfPresent(String.self, forKey: .preferredLanguage)
        preferredCurrency = try container.decodeIfPresent(String.self, forKey: .preferredCurrency)
        signedInWithProvider = try container.decodeIfPresent(Bool.self, forKey: .signedInWithProvider)
        loyaltyProvider = try container.decodeIfPresent(LoyaltyProvider.self, forKey: .loyaltyProvider)
        mokafaaEnrollment = try container.decodeIfPresent(MokafaaEnrollment.self, forKey: .mokafaaEnrollment)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encodeIfPresent(phoneNumber, forKey: .phoneNumber)
        try container.encodeIfPresent(firstName, forKey: .firstName)
        try container.encodeIfPresent(lastName, forKey: .lastName)
        try container.encodeIfPresent(fullName, forKey: .fullName)
        try container.encodeIfPresent(referralCode, forKey: .referralCode)
        try container.encodeIfPresent(externalReference, forKey: .externalReference)
        try container.encodeIfPresent(acquisitionSource, forKey: .acquisitionSource)
        try container.encodeIfPresent(customerId, forKey: .customerId)
        try container.encodeIfPresent(receiveMarketingEmail, forKey: .receiveMarketingEmail)
        try container.encodeIfPresent(receiveMarketingPush, forKey: .receiveMarketingPush)
        try container.encodeIfPresent(receiveAccountEmail, forKey: .receiveAccountEmail)
        try container.encodeIfPresent(receiveAccountSms, forKey: .receiveAccountSms)
        try container.encodeIfPresent(receiveAccountPush, forKey: .receiveAccountPush)
        try container.encodeIfPresent(receivePurchaseEmail, forKey: .receivePurchaseEmail)
        try container.encodeIfPresent(receivePurchasePush, forKey: .receivePurchasePush)
        try container.encodeIfPresent(receiveViberMessages, forKey: .receiveViberMessages)
        try container.encodeIfPresent(preferredLanguage, forKey: .preferredLanguage)
        try container.encodeIfPresent(preferredCurrency, forKey: .preferredCurrency)
        try container.encodeIfPresent(signedInWithProvider, forKey: .signedInWithProvider)
        try container.encodeIfPresent(loyaltyProvider, forKey: .loyaltyProvider)
        try container.encodeIfPresent(mokafaaEnrollment, forKey: .mokafaaEnrollment)
    }
}
