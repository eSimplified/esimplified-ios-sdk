//
//  MokafaaRepositoryType.swift
//  EsimplifiedSDK
//

import Foundation

public protocol MokafaaRepositoryType: Sendable {
    func initiateOtp(purpose: MokafaaOtpPurpose) async throws -> MokafaaOtpInitiateResponse
    func validateOtp(sessionId: String, otp: String, points: Int?) async throws -> MokafaaOtpValidateResponse
}
