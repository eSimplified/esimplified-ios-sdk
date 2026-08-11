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
    public var customerId: String? = ""
    public var receiveEmails: Bool? = true
    public var receivePushNotifications: Bool? = true
    public var receiveSms: Bool? = true
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
        case externalReference = "external_reference"
        case customerId = "customer_id"
        case receiveEmails = "receive_emails"
        case receivePushNotifications = "receive_push_notifications"
        case receiveSms = "receive_sms"
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
        customerId: String? = "",
        receiveEmails: Bool? = true,
        receivePushNotifications: Bool? = true,
        receiveSms: Bool? = true,
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
        self.customerId = customerId
        self.receiveEmails = receiveEmails
        self.receivePushNotifications = receivePushNotifications
        self.receiveSms = receiveSms
        self.preferredLanguage = preferredLanguage
        self.preferredCurrency = preferredCurrency
        self.signedInWithProvider = signedInWithProvider
        self.loyaltyProvider = loyaltyProvider
        self.mokafaaEnrollment = mokafaaEnrollment
    }
}
