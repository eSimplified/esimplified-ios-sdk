//
//  PaymentsRepositoryType.swift
//  EsimplifiedSDK
//

import Foundation

public protocol PaymentsRepositoryType {
    func fetchPayment(
        transactionType: TransactionType,
        packageTypeId: Int,
        email: String,
        iccid: String?,
        autoTopUp: Bool,
        savePaymentDetail: Bool,
        loyaltyPointsAmount: Double?
    ) async throws -> PaymentData
    func sendKredsQuote(packageTypeId: Int, loyaltyPointsAmount: Double) async throws -> KredsQuoteResponse
}
