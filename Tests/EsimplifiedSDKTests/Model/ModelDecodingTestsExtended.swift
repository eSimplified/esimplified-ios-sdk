//
//  ModelDecodingTestsExtended.swift
//  EsimplifiedSDK
//
//  Decoding round-trip coverage for every public response model.
//

import Testing
import Foundation
@testable import EsimplifiedSDK

@Suite("Model Decoding - Extended")
struct ModelDecodingTestsExtended {

    private func decode<T: Decodable>(_ json: String) throws -> T {
        let data = json.data(using: .utf8)!
        return try JSONDecoder().decode(T.self, from: data)
    }

    // MARK: - Auth responses

    @Test("SignInCustomerResponse decodes all token fields")
    func signInCustomerResponse() throws {
        let json = #"""
        {"access_token":"at","expires_in":3600,"token_type":"Bearer","scope":"all","refresh_token":"rt","user":{"email":"a@b.com"}}
        """#
        let r: SignInCustomerResponse = try decode(json)
        #expect(r.accessToken == "at")
        #expect(r.tokenExpiresIn == 3600)
        #expect(r.tokenType == "Bearer")
        #expect(r.refreshToken == "rt")
        #expect(r.user?.email == "a@b.com")
    }

    @Test("SignInCustomerResponse handles null refresh_token")
    func signInResponseNullRefresh() throws {
        let json = #"{"access_token":"at","expires_in":3600,"token_type":"Bearer","scope":"all","refresh_token":null,"user":null}"#
        let r: SignInCustomerResponse = try decode(json)
        #expect(r.refreshToken == nil)
    }

    @Test("SignInCustomerResponse decodes loyalty fields on user")
    func signInResponseLoyaltyFields() throws {
        let json = #"""
        {"access_token":"at","expires_in":3600,"token_type":"Bearer","scope":"all","refresh_token":"rt","user":{"email":"a@b.com","loyalty_provider":"mokafaa","mokafaa_enrollment":{"state":"pending","session_expires_at":"2026-08-11T10:05:00Z"}}}
        """#
        let r: SignInCustomerResponse = try decode(json)
        #expect(r.user?.loyaltyProvider == .mokafaa)
        #expect(r.user?.mokafaaEnrollment?.state == .pending)
        #expect(r.user?.mokafaaEnrollment?.sessionExpiresAt == "2026-08-11T10:05:00Z")
    }

    @Test("VerifyEmailResponse decodes email_verified")
    func verifyEmailResponse() throws {
        let json = #"{"email":"a@b.com","email_verified":true}"#
        let r: VerifyEmailResponse = try decode(json)
        #expect(r.email == "a@b.com")
        #expect(r.email_verified == true)
    }

    @Test("ForgotPasswordResponse decodes with customer_id snake_case")
    func forgotPasswordResponse() throws {
        let json = #"{"email":"a@b.com","detail":"sent","customer_id":"c-123"}"#
        let r: ForgotPasswordResponse = try decode(json)
        #expect(r.email == "a@b.com")
        #expect(r.customerID == "c-123")
    }

    @Test("ChangePasswordResponse decodes password_reset")
    func changePasswordResponse() throws {
        let json = #"{"password_reset":true}"#
        let r: ChangePasswordResponse = try decode(json)
        #expect(r.password_reset == true)
    }

    @Test("DeleteAccountResponse decodes deleted flag")
    func deleteAccountResponse() throws {
        let json = #"{"deleted":true}"#
        let r: DeleteAccountResponse = try decode(json)
        #expect(r.deleted == true)
    }

    @Test("RegisterCustomerResponse decodes with referral_code")
    func registerCustomerResponse() throws {
        let json = #"{"message":"ok","success":true,"email":"a@b.com","referral_code":"ABC123"}"#
        let r: RegisterCustomerResponse = try decode(json)
        #expect(r.success == true)
        #expect(r.referralCode == "ABC123")
    }

    // MARK: - User

    @Test("User decodes all snake_case fields")
    func userDecoding() throws {
        let json = #"""
        {"email":"a@b.com","phone_number":"+1234","first_name":"A","last_name":"B","full_name":"A B","referral_code":"R","external_reference":"E","customer_id":"C","receive_emails":true,"receive_push_notifications":false,"receive_sms":true,"preferred_language":"en","preferred_currency":"USD","signed_in_with_provider":false,"loyalty_provider":"kreds"}
        """#
        let r: User = try decode(json)
        #expect(r.email == "a@b.com")
        #expect(r.phoneNumber == "+1234")
        #expect(r.firstName == "A")
        #expect(r.lastName == "B")
        #expect(r.fullName == "A B")
        #expect(r.referralCode == "R")
        #expect(r.preferredLanguage == "en")
        #expect(r.preferredCurrency == "USD")
        #expect(r.loyaltyProvider == .kreds)
    }

    @Test("User loyaltyProvider mokafaa case")
    func userLoyaltyProviderMokafaa() throws {
        let json = #"{"loyalty_provider":"mokafaa"}"#
        let r: User = try decode(json)
        #expect(r.loyaltyProvider == .mokafaa)
    }

    // MARK: - Promo / Vouchers

    @Test("PromoCodeResponse decodes valid -> isValid")
    func promoCodeResponse() throws {
        let json = #"{"valid":true,"discount_code":"SAVE","discount_percentage":0.15,"detail":"applied","product_type":"esim"}"#
        let r: PromoCodeResponse = try decode(json)
        #expect(r.isValid == true)
        #expect(r.discountCode == "SAVE")
        #expect(r.discountPercentage == 0.15)
        #expect(r.productType == "esim")
    }

    @Test("VoucherRedeemResponse decodes with redirect URL")
    func voucherRedeemResponse() throws {
        let json = #"{"redeemed":true,"redirect_url":"https://example.com/o/123"}"#
        let r: VoucherRedeemResponse = try decode(json)
        #expect(r.redeemed == true)
        #expect(r.redirectUrl == "https://example.com/o/123")
    }

    // MARK: - Visa rewards

    @Test("VisaRewardResponse decodes with iframe_url")
    func visaRewardResponse() throws {
        let json = #"{"created":true,"token":"tok","iframe_url":"https://visa/iframe","eligible":true,"status":1}"#
        let r: VisaRewardResponse = try decode(json)
        #expect(r.token == "tok")
        #expect(r.iframeURL == "https://visa/iframe")
        #expect(r.eligible == true)
    }

    @Test("VisaValidateResponse decodes with DISCOUNT reward type")
    func visaValidateResponseDiscount() throws {
        let json = #"{"eligible":true,"used_count":1,"reward_type":"DISCOUNT","allowed_count":3,"remaining_count":2,"redeemed":false,"detail":"ok"}"#
        let r: VisaValidateResponse = try decode(json)
        #expect(r.eligible == true)
        #expect(r.rewardType == .discount)
        #expect(r.remainingCount == 2)
    }

    @Test("VisaValidateResponse decodes with GLOBAL_ESIM reward type")
    func visaValidateResponseGlobalEsim() throws {
        let json = #"{"eligible":true,"reward_type":"GLOBAL_ESIM"}"#
        let r: VisaValidateResponse = try decode(json)
        #expect(r.rewardType == .global)
    }

    @Test("VisaValidateResponse decodes unknown reward_type to .unknown")
    func visaValidateResponseUnknownType() throws {
        let json = #"{"eligible":false,"reward_type":"BOGUS"}"#
        let r: VisaValidateResponse = try decode(json)
        #expect(r.rewardType == .unknown)
    }

    @Test("RedeemVisaResponse decodes redirect_url")
    func redeemVisaResponse() throws {
        let json = #"{"redeemed":true,"detail":"ok","redirect_url":"https://example.com"}"#
        let r: RedeemVisaResponse = try decode(json)
        #expect(r.redeemed == true)
        #expect(r.redirectURL == "https://example.com")
    }

    // MARK: - Misc

    @Test("NotificationSettings decodes type and enabled")
    func notificationSettings() throws {
        let json = #"{"type":"marketing","enabled":true}"#
        let r: NotificationSettings = try decode(json)
        #expect(r.type == "marketing")
        #expect(r.enabled == true)
    }

    @Test("UpdateEsimResponse decodes message")
    func updateEsimResponse() throws {
        let json = #"{"message":"eSIM updated successfully"}"#
        let r: UpdateEsimResponse = try decode(json)
        #expect(r.message == "eSIM updated successfully")
    }

    @Test("TrackedOrderResponse decodes conversion_tracked")
    func trackedOrderResponse() throws {
        let json = #"{"detail":"ok","conversion_tracked":true}"#
        let r: TrackedOrderResponse = try decode(json)
        #expect(r.conversionTracked == true)
    }

    @Test("ApiErrorResponse decodes detail and error")
    func apiErrorResponse() throws {
        let json = #"{"error":"validation","detail":"Field missing"}"#
        let r: ApiErrorResponse = try decode(json)
        #expect(r.error == "validation")
        #expect(r.detail == "Field missing")
    }

    @Test("ServerErrorResponse decodes error_description")
    func serverErrorResponse() throws {
        let json = #"{"error":"invalid_grant","error_description":"Bad credentials"}"#
        let r: ServerErrorResponse = try decode(json)
        #expect(r.errorDescription == "Bad credentials")
    }

    // MARK: - Mokafaa

    @Test("MokafaaOtpInitiateResponse decodes session_id and expires_at")
    func mokafaaInitiateResponse() throws {
        let json = #"{"session_id":"sess-1","expires_at":"2026-12-31T00:00:00Z","masked_phone_number":"+966*****1234"}"#
        let r: MokafaaOtpInitiateResponse = try decode(json)
        #expect(r.sessionId == "sess-1")
        #expect(r.expiresAt == "2026-12-31T00:00:00Z")
    }

    @Test("MokafaaOtpValidateResponse decodes status and points fields")
    func mokafaaValidateResponse() throws {
        let json = #"{"status":"confirmed","points_redeemed":500,"points_balance":1500}"#
        let r: MokafaaOtpValidateResponse = try decode(json)
        #expect(r.status == .confirmed)
        #expect(r.pointsRedeemed == 500)
        #expect(r.pointsBalance == 1500)
    }

    @Test("MokafaaOtpStatus decodes all 3 cases")
    func mokafaaOtpStatusCases() throws {
        struct W: Codable { let status: MokafaaOtpStatus }
        #expect((try decode(#"{"status":"confirmed"}"#) as W).status == .confirmed)
        #expect((try decode(#"{"status":"reversed"}"#) as W).status == .reversed)
        #expect((try decode(#"{"status":"failed"}"#) as W).status == .failed)
    }

    @Test("MokafaaOtpPurpose decodes both cases")
    func mokafaaOtpPurposeCases() throws {
        struct W: Codable { let purpose: MokafaaOtpPurpose }
        #expect((try decode(#"{"purpose":"enrollment"}"#) as W).purpose == .enrollment)
        #expect((try decode(#"{"purpose":"checkout"}"#) as W).purpose == .checkout)
    }

    // MARK: - Enums and provider

    @Test("LoyaltyProvider decodes kreds and mokafaa")
    func loyaltyProviderCases() throws {
        struct W: Codable { let p: LoyaltyProvider }
        #expect((try decode(#"{"p":"kreds"}"#) as W).p == .kreds)
        #expect((try decode(#"{"p":"mokafaa"}"#) as W).p == .mokafaa)
    }

    @Test("AuthProvider decodes apple and google")
    func authProviderCases() throws {
        struct W: Codable { let p: AuthProvider }
        #expect((try decode(#"{"p":"apple"}"#) as W).p == .apple)
        #expect((try decode(#"{"p":"google"}"#) as W).p == .google)
    }

    // MARK: - Loyalty

    @Test("KredsLoyaltyBalanceResponse decodes nested LoyaltyPointsDetail")
    func kredsBalanceResponse() throws {
        let json = #"""
        {
            "total_loyalty_points": 1500,
            "total_loyalty_points_detail": {
                "amount": "15.00",
                "currency": {"symbol": "$", "iso": "USD"},
                "amount_local_currency": "5.65"
            }
        }
        """#
        let r: KredsLoyaltyBalanceResponse = try decode(json)
        #expect(r.totalLoyaltyPoints == 1500)
        #expect(r.totalLoyaltyPointsDetail.amount == "15.00")
        #expect(r.totalLoyaltyPointsDetail.currency.symbol == "$")
        #expect(r.totalLoyaltyPointsDetail.currency.iso == "USD")
    }

    // MARK: - Payment-related

    @Test("PaymentResponse decodes detail and nested PaymentData (data key)")
    func paymentResponse() throws {
        let json = #"""
        {"detail":"ok","data":{"uri":"pi_secret","order_id":"o1","is_intent":true,"customer_ref":"cr","ephemeral_key":"ek","publishable_key":"pk","zero_charge":false}}
        """#
        let r: PaymentResponse = try decode(json)
        #expect(r.detail == "ok")
        #expect(r.paymentData.uri == "pi_secret")
        #expect(r.paymentData.orderID == "o1")
        #expect(r.paymentData.isIntent == true)
        #expect(r.paymentData.publishableKey == "pk")
    }

    @Test("TransactionType decodes buy and topUp")
    func transactionTypeCases() throws {
        struct W: Codable { let t: TransactionType }
        let buy: W = try decode(#"{"t":"buy"}"#)
        #expect(buy.t == .buy)
        let topUp: W = try decode(#"{"t":"top-up"}"#)
        #expect(topUp.t == .topUp)
    }

    // MARK: - Store review

    @Test("StoreReviewResponse decodes average_rating and review_count")
    func storeReviewResponse() throws {
        let json = #"{"average_rating":"4.5","review_count":1234,"verdict":"GREAT"}"#
        let r: StoreReviewResponse = try decode(json)
        #expect(r.averageRating == "4.5")
        #expect(r.reviewCount == 1234)
        #expect(r.verdict == "GREAT")
    }
}
