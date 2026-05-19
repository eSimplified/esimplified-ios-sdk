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
        transactionType: TransactionType,
        packageTypeId: Int,
        email: String,
        iccid: String?,
        autoTopUp: Bool,
        savePaymentDetail: Bool,
        loyaltyPointsAmount: Double?
    ) async throws -> PaymentData {
        let paymentBody = PaymentRequest(
            type: transactionType,
            packageTypeId: String(packageTypeId),
            iccid: iccid,
            customer: CustomerEmail(email: email),
            autoTopUp: autoTopUp,
            savePaymentMethod: savePaymentDetail,
            loyaltyPointsAmount: loyaltyPointsAmount
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
            packageTypeId: packageTypeId,
            loyaltyPointsAmount: loyaltyPointsAmount
        )
        return try await client.fetch(
            endpoint: .paymentsQuote,
            method: .POST,
            body: quoteRequest
        )
    }
}
