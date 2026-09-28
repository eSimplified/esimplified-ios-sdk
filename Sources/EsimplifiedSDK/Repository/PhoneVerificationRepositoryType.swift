//
//  PhoneVerificationRepositoryType.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/09/28.
//

import Foundation

public protocol PhoneVerificationRepositoryType {
    func sendCode(phoneNumber: String, channel: PhoneOtpChannel) async throws -> PhoneOtpSendResponse
    func verifyCode(_ code: String) async throws -> PhoneOtpVerifyResponse
}
