//
//  PhoneVerificationRepositoryType.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/09/28.
//

import Foundation

public protocol PhoneVerificationRepositoryType {
    /// Sends a one-time code to the number. The code lasts 10 minutes.
    func sendCode(phoneNumber: String, channel: PhoneOtpChannel) async throws -> PhoneOtpSendResponse
    /// Submits the code the customer received. Re-fetch the customer afterwards.
    func verifyCode(_ code: String) async throws -> PhoneOtpVerifyResponse
}
