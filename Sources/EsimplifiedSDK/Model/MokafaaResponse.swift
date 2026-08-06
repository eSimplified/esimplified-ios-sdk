//
//  MokafaaResponse.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/06/04.
//

import Foundation

// MARK: Mokafaa OTP Purpose

public enum MokafaaOtpPurpose: String, Codable {
    case enrollment
    case checkout
}

// MARK: Mokafaa OTP Status

public enum MokafaaOtpStatus: String, Codable {
    case confirmed
    case reversed
    case failed
}

// MARK: Mokafaa OTP Initiate Request

public struct MokafaaOtpInitiateRequest: Codable {
    public let purpose: MokafaaOtpPurpose
    public let platform: String

    public init(purpose: MokafaaOtpPurpose) {
        self.purpose = purpose
        self.platform = "ios"
    }
}

// MARK: Mokafaa OTP Initiate Response

public struct MokafaaOtpInitiateResponse: Codable {
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

public struct MokafaaOtpValidateRequest: Codable {
    public let sessionId: String
    public let otp: String
    public let points: Int?
    /// Checkout purpose only: lets the backend reject the redemption before burning points
    /// when the residual card charge would fall below Stripe's minimum. Ignored for enrollment.
    public let packageTypeId: Int?

    public init(sessionId: String, otp: String, points: Int? = nil, packageTypeId: Int? = nil) {
        self.sessionId = sessionId
        self.otp = otp
        self.points = points
        self.packageTypeId = packageTypeId
    }

    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case otp
        case points
        case packageTypeId = "package_type_id"
    }
}

// MARK: Mokafaa OTP Validate Response

public struct MokafaaOtpValidateResponse: Codable {
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
