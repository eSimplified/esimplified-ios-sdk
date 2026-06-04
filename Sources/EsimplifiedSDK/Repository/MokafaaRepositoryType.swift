//
//  MokafaaRepositoryType.swift
//  EsimplifiedSDK
//

import Foundation

public protocol MokafaaRepositoryType: Sendable {
    /// Initiates a Mokafaa OTP session.
    /// - Parameter purpose: `.enrollment` for linking a Mokafaa account, `.checkout` for a points burn.
    /// - Returns: A session containing `sessionId`, `expiresAt` (ISO 8601 string), and an optional masked phone.
    func initiateOtp(purpose: MokafaaOtpPurpose) async throws -> MokafaaOtpInitiateResponse

    /// Validates an OTP and optionally burns points in the same call.
    /// - Parameters:
    ///   - sessionId: The `sessionId` from `initiateOtp`.
    ///   - otp: The user-entered code.
    ///   - points: The points to redeem. `nil` for enrollment, required for checkout.
    /// - Returns: Status (`confirmed` / `reversed` / `failed`) and optional `pointsRedeemed` / `pointsBalance`.
    func validateOtp(sessionId: String, otp: String, points: Int?) async throws -> MokafaaOtpValidateResponse
}
