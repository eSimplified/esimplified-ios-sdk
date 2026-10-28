//
//  PaymentsRepositoryImpl.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/06/04.
//

import Foundation

final class PaymentsRepositoryImpl: PaymentsRepositoryType {

    private let client: HTTPClient
    private let sessionProvider: SessionProvider

    init(client: HTTPClient, sessionProvider: SessionProvider) {
        self.client = client
        self.sessionProvider = sessionProvider
    }

    func fetchPayment(
        transactionType: TransactionType,
        packageTypeId: Int,
        iccid: String?,
        autoTopUp: Bool,
        savePaymentDetail: Bool,
        loyaltyPointsAmount: Double?
    ) async throws -> PaymentData {
        let paymentBody = PaymentRequest(
            type: transactionType,
            package_type_id: String(packageTypeId),
            iccid: iccid,
            customer: CustomerEmail(email: sessionProvider.getUserEmail() ?? ""),
            auto_top_up: autoTopUp,
            save_payment_method: savePaymentDetail,
            loyalty_points_amount: loyaltyPointsAmount
        )
        let response: PaymentResponse = try await client.fetch(
            endpoint: .payments,
            method: .POST,
            body: paymentBody
        )
        return response.paymentData
    }

    func startSmartPayPayment(
        transactionType: TransactionType,
        packageTypeId: Int,
        iccid: String?,
        loyaltyPointsAmount: Double?,
        redirectUrl: String
    ) async throws -> PaymentData {
        let paymentBody = PaymentRequest(
            type: transactionType,
            payment_method: .smartpay,
            package_type_id: String(packageTypeId),
            iccid: iccid,
            customer: CustomerEmail(email: sessionProvider.getUserEmail() ?? ""),
            auto_top_up: false,
            loyalty_points_amount: loyaltyPointsAmount,
            redirect_url: redirectUrl
        )
        let response: PaymentResponse = try await client.fetch(
            endpoint: .payments,
            method: .POST,
            body: paymentBody
        )
        return response.paymentData
    }

    func sendKredsQuote(packageTypeId: Int, loyaltyPointsAmount: Double) async throws -> KredsQuoteResponse {
        let quoteRequest = KredsQuoteRequest(
            package_type_id: packageTypeId,
            loyalty_points_amount: loyaltyPointsAmount
        )
        return try await client.fetch(
            endpoint: .paymentsQuote,
            method: .POST,
            body: quoteRequest
        )
    }

    func fetchPaymentMethods() async throws -> [SavedPaymentMethod] {
        try await client.fetch(endpoint: .paymentMethods, method: .GET)
    }

    func fetchPaymentMethods(eligibleFor discountCode: String) async throws -> [SavedPaymentMethod] {
        try await client.fetch(
            endpoint: .paymentMethods,
            method: .GET,
            parameters: ["discount_code": discountCode]
        )
    }

    func deletePaymentMethod(_ paymentMethodID: String) async throws {
        let _: EmptyResponse = try await client.fetch(
            endpoint: .paymentMethod,
            method: .DELETE,
            id: paymentMethodID
        )
    }

    func createPaymentMethodSetupIntent() async throws -> PaymentMethodSetupIntent {
        try await client.fetch(endpoint: .paymentMethodSetupIntent, method: .POST)
    }

    func verifyPaymentMethod(_ paymentMethodID: String, discountCode: String) async throws -> SavedPaymentMethod {
        let verificationBody = PaymentMethodVerificationRequest(
            payment_method_id: paymentMethodID,
            discount_code: discountCode
        )
        return try await client.fetch(
            endpoint: .paymentMethodVerify,
            method: .POST,
            body: verificationBody
        )
    }

    func payWithStoredPaymentMethod(
        _ paymentMethodID: String,
        transactionType: TransactionType,
        packageTypeId: Int,
        iccid: String?,
        discountCode: String?
    ) async throws -> PaymentData {
        let paymentBody = PaymentRequest(
            type: transactionType,
            package_type_id: String(packageTypeId),
            iccid: iccid,
            customer: CustomerEmail(email: sessionProvider.getUserEmail() ?? ""),
            stored_payment_method: paymentMethodID,
            discount_code: discountCode
        )
        let response: PaymentResponse = try await client.fetch(
            endpoint: .payments,
            method: .POST,
            body: paymentBody
        )
        return response.paymentData
    }
}
