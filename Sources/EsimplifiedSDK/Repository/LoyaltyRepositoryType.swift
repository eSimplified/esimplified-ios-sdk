//
//  LoyaltyRepositoryType.swift
//  EsimplifiedSDK
//

import Foundation

public protocol LoyaltyRepositoryType {
    func fetchKredsBalance(forceRefresh: Bool, cacheTTL: TimeInterval) async throws -> KredsLoyaltyBalanceResponse
    func initiateOtp(purpose: MokafaaOtpPurpose) async throws -> MokafaaOtpInitiateResponse
    func validateOtp(sessionId: String, otp: String, points: Int?, packageTypeId: Int?) async throws -> MokafaaOtpValidateResponse
    func invalidateCache() async
}

public extension LoyaltyRepositoryType {
    func fetchKredsBalance(forceRefresh: Bool = true) async throws -> KredsLoyaltyBalanceResponse {
        try await fetchKredsBalance(forceRefresh: forceRefresh, cacheTTL: 3600)
    }

    func validateOtp(sessionId: String, otp: String, points: Int? = nil) async throws -> MokafaaOtpValidateResponse {
        try await validateOtp(sessionId: sessionId, otp: otp, points: points, packageTypeId: nil)
    }
}
