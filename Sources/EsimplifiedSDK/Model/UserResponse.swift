//
//  UserResponse.swift
//  KnowRoaming
//
//  Created by Kieran on 2025/02/17.
//

import Foundation

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
        signedInWithProvider: Bool? = nil
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
    }
}
