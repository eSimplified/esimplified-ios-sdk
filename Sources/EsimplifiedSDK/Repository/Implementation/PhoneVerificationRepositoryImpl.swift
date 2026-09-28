//
//  PhoneVerificationRepositoryImpl.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/09/28.
//

import Foundation

final class PhoneVerificationRepositoryImpl: PhoneVerificationRepositoryType {

    private let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }

    func sendCode(phoneNumber: String, channel: PhoneOtpChannel) async throws -> PhoneOtpSendResponse {
        try await client.fetch(
            endpoint: .phoneOtp,
            method: .POST,
            body: PhoneOtpSendRequest(phoneNumber: phoneNumber, channel: channel)
        )
    }

    func verifyCode(_ code: String) async throws -> PhoneOtpVerifyResponse {
        try await client.fetch(
            endpoint: .phoneOtpVerify,
            method: .POST,
            body: ["code": code]
        )
    }
}
