//
//  MokafaaRepositoryImpl.swift
//  EsimplifiedSDK
//

import Foundation

final class MokafaaRepositoryImpl: MokafaaRepositoryType {

    private let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }

    func initiateOtp(purpose: MokafaaOtpPurpose) async throws -> MokafaaOtpInitiateResponse {
        let body = MokafaaOtpInitiateRequest(purpose: purpose)
        return try await client.fetch(
            endpoint: .mokafaaOtpInitiate,
            method: .POST,
            body: body
        )
    }

    func validateOtp(sessionId: String, otp: String, points: Int?) async throws -> MokafaaOtpValidateResponse {
        let body = MokafaaOtpValidateRequest(sessionId: sessionId, otp: otp, points: points)
        return try await client.fetch(
            endpoint: .mokafaaOtpValidate,
            method: .POST,
            body: body
        )
    }
}
