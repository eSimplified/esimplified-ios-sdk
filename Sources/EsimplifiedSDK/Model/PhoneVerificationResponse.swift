//
//  PhoneVerificationResponse.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/09/28.
//

import Foundation

// MARK: Phone OTP Channel

public enum PhoneOtpChannel: String, Codable {
    case sms
    case whatsapp
}

// MARK: Phone OTP Send Request

public struct PhoneOtpSendRequest: Codable {
    public let phoneNumber: String
    public let channel: PhoneOtpChannel

    enum CodingKeys: String, CodingKey {
        case phoneNumber = "phone_number"
        case channel
    }

    public init(phoneNumber: String, channel: PhoneOtpChannel) {
        self.phoneNumber = phoneNumber
        self.channel = channel
    }
}

// MARK: Phone OTP Send Response

public struct PhoneOtpSendResponse: Codable {
    public let phoneNumber: String
    public let channel: PhoneOtpChannel

    enum CodingKeys: String, CodingKey {
        case phoneNumber = "phone_number"
        case channel
    }

    public init(phoneNumber: String, channel: PhoneOtpChannel) {
        self.phoneNumber = phoneNumber
        self.channel = channel
    }
}

// MARK: Phone OTP Verify Response

public struct PhoneOtpVerifyResponse: Codable {
    public let phoneNumber: String
    public let phoneVerified: Bool

    enum CodingKeys: String, CodingKey {
        case phoneNumber = "phone_number"
        case phoneVerified = "phone_verified"
    }

    public init(phoneNumber: String, phoneVerified: Bool) {
        self.phoneNumber = phoneNumber
        self.phoneVerified = phoneVerified
    }
}
