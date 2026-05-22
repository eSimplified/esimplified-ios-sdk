//
//  PaymentsRepositoryImpl.swift
//  EsimplifiedSDK
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
}
