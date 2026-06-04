//
//  MokafaaResponse.swift
//  EsimplifiedSDK
//

import Foundation

// MARK: Mokafaa OTP Purpose

public enum MokafaaOtpPurpose: String, Codable, Sendable {
    case enrollment
    case checkout
}

// MARK: Mokafaa Platform

public enum MokafaaPlatform: String, Codable, Sendable {
    case ios
}

// MARK: Mokafaa OTP Status

public enum MokafaaOtpStatus: String, Codable, Sendable {
    case confirmed
    case reversed
    case failed
}

// MARK: Mokafaa OTP Initiate Request

public struct MokafaaOtpInitiateRequest: Codable, Sendable {
    public let purpose: MokafaaOtpPurpose
    public let platform: MokafaaPlatform

    public init(purpose: MokafaaOtpPurpose, platform: MokafaaPlatform = .ios) {
        self.purpose = purpose
        self.platform = platform
    }
}

// MARK: Mokafaa OTP Initiate Response

public struct MokafaaOtpInitiateResponse: Codable, Sendable {
    public let sessionId: String
    public let expiresAt: String
    public let maskedPhoneNumber: String?

    public init(sessionId: String, expiresAt: String, maskedPhoneNumber: String? = nil) {
        self.sessionId = sessionId
        self.expiresAt = expiresAt
        self.maskedPhoneNumber = maskedPhoneNumber
    }

    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case expiresAt = "expires_at"
        case maskedPhoneNumber = "masked_phone_number"
    }
}

// MARK: Mokafaa OTP Validate Request

public struct MokafaaOtpValidateRequest: Codable, Sendable {
    public let sessionId: String
    public let otp: String
    public let points: Int?

    public init(sessionId: String, otp: String, points: Int? = nil) {
        self.sessionId = sessionId
        self.otp = otp
        self.points = points
    }

    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case otp
        case points
    }
}

// MARK: Mokafaa OTP Validate Response

public struct MokafaaOtpValidateResponse: Codable, Sendable {
    public let status: MokafaaOtpStatus
    public let pointsRedeemed: Int?
    public let pointsBalance: Int?

    public init(status: MokafaaOtpStatus, pointsRedeemed: Int? = nil, pointsBalance: Int? = nil) {
        self.status = status
        self.pointsRedeemed = pointsRedeemed
        self.pointsBalance = pointsBalance
    }

    enum CodingKeys: String, CodingKey {
        case status
        case pointsRedeemed = "points_redeemed"
        case pointsBalance = "points_balance"
    }
}
