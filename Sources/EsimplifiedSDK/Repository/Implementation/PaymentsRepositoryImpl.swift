//
//  PaymentsRepositoryImpl.swift
//  EsimplifiedSDK
//

import Foundation

final class PaymentsRepositoryImpl: PaymentsRepositoryType {

    private let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }

    func fetchPayment(
        email: String,
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
            customer: CustomerEmail(email: email),
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
