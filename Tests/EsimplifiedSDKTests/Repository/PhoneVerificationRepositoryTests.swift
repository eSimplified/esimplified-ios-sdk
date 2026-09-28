//
//  PhoneVerificationRepositoryTests.swift
//  EsimplifiedSDK
//

import Testing
import Foundation
@testable import EsimplifiedSDK

extension NetworkSuite {

    private func makePhoneRepo() -> PhoneVerificationRepositoryImpl {
        let config = SdkConfig(environment: .staging, clientName: "acme", clientId: "id", clientSecret: "secret")
        let session = RecordingSessionProvider(
            initial: .authenticated(accessToken: "a", refreshToken: "r", expiresAt: Date().addingTimeInterval(3600))
        )
        let client = HTTPClient(config: config, sessionProvider: session, session: MockSession.make())
        return PhoneVerificationRepositoryImpl(client: client)
    }

    private func capturedJsonBody(at index: Int = 0) -> [String: String]? {
        guard let data = MockURLProtocol.capturedBodies[index] else { return nil }
        return try? JSONDecoder().decode([String: String].self, from: data)
    }

    @Test("Phone: sendCode posts the number and channel to customer/phone/otp with the customer token")
    func phoneSendCode() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: #"{"phone_number":"+27821234567","channel":"whatsapp"}"#)

        let response = try await makePhoneRepo().sendCode(phoneNumber: "+27 82 123 4567", channel: .whatsapp)

        let request = MockURLProtocol.capturedRequests.first
        #expect(request?.url?.path.hasSuffix("/customer/phone/otp") == true)
        #expect(request?.httpMethod == "POST")
        #expect(request?.value(forHTTPHeaderField: "Authorization") == "Bearer a")
        #expect(capturedJsonBody() == ["phone_number": "+27 82 123 4567", "channel": "whatsapp"])
        #expect(response.phoneNumber == "+27821234567")
        #expect(response.channel == .whatsapp)
    }

    @Test("Phone: verifyCode posts the code to customer/phone/otp/verify")
    func phoneVerifyCode() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: #"{"phone_number":"+27821234567","phone_verified":true}"#)

        let response = try await makePhoneRepo().verifyCode("123456")

        let request = MockURLProtocol.capturedRequests.first
        #expect(request?.url?.path.hasSuffix("/customer/phone/otp/verify") == true)
        #expect(request?.httpMethod == "POST")
        #expect(capturedJsonBody() == ["code": "123456"])
        #expect(response.phoneVerified)
    }

    @Test("Phone: a wrong code surfaces the API's error code and translated detail")
    func phoneWrongCode() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(
            statusCode: 400,
            json: #"{"code":"invalid_code","detail":"That code is not right."}"#
        )

        do {
            _ = try await makePhoneRepo().verifyCode("000000")
            Issue.record("expected a throw")
        } catch let error as SdkError {
            #expect(error.statusCode == 400)
            #expect(error.apiCode == "invalid_code")
            #expect(error.hasApiCode(.invalidCode))
            #expect(error.errorDescription == "That code is not right.")
        }
    }

    @Test("Phone: a number owned by another account is a 409 phone_already_verified")
    func phoneAlreadyVerified() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(
            statusCode: 409,
            json: #"{"code":"phone_already_verified","detail":"Already in use."}"#
        )

        do {
            _ = try await makePhoneRepo().sendCode(phoneNumber: "+27821234567", channel: .sms)
            Issue.record("expected a throw")
        } catch let error as SdkError {
            #expect(error.statusCode == 409)
            #expect(error.hasApiCode(.phoneAlreadyVerified))
        }
    }

    @Test("Phone: a 403 phone_verification_required is returned as-is, without a token refresh")
    func phoneVerificationRequiredSkipsRefresh() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(
            statusCode: 403,
            json: #"{"code":"phone_verification_required","detail":"Verify your phone first."}"#
        )
        let config = SdkConfig(environment: .staging, clientName: "acme", clientId: "id", clientSecret: "secret")
        let session = RecordingSessionProvider(
            initial: .authenticated(accessToken: "a", refreshToken: "r", expiresAt: Date().addingTimeInterval(3600))
        )
        let client = HTTPClient(config: config, sessionProvider: session, session: MockSession.make())
        let repo = VisaRewardsRepositoryImpl(client: client)

        do {
            _ = try await repo.fetchVisaReward(isEU: false)
            Issue.record("expected a throw")
        } catch let error as SdkError {
            #expect(error.statusCode == 403)
            #expect(error.hasApiCode(.phoneVerificationRequired))
        }
        #expect(MockURLProtocol.capturedRequests.count == 1, "a business-rule 403 must not trigger a refresh and retry")
        #expect(session.tokenRefreshedCalls.isEmpty)
    }

    @Test("Phone: a plain 403 still refreshes and retries")
    func plain403StillRefreshes() async throws {
        MockURLProtocol.reset()
        let refreshJson = #"{"access_token":"new","expires_in":3600,"token_type":"Bearer","scope":"all","refresh_token":"new-r"}"#
        MockURLProtocol.handler = MockSession.sequence([
            (statusCode: 403, json: #"{"detail":"Authentication credentials were not provided."}"#),
            (statusCode: 200, json: refreshJson),
            (statusCode: 200, json: #"{"phone_number":"+27821234567","channel":"sms"}"#)
        ])

        _ = try await makePhoneRepo().sendCode(phoneNumber: "+27821234567", channel: .sms)
        #expect(MockURLProtocol.capturedRequests.count == 3)
    }
}
