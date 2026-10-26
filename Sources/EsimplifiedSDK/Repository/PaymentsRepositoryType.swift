//
//  PaymentsRepositoryType.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/06/04.
//

import Foundation

public protocol PaymentsRepositoryType {
    func fetchPayment(transactionType: TransactionType, packageTypeId: Int, iccid: String?, autoTopUp: Bool, savePaymentDetail: Bool, loyaltyPointsAmount: Double?) async throws -> PaymentData
    func sendKredsQuote(packageTypeId: Int, loyaltyPointsAmount: Double) async throws -> KredsQuoteResponse
    func startSmartPayPayment(
        transactionType: TransactionType,
        packageTypeId: Int,
        iccid: String?,
        loyaltyPointsAmount: Double?,
        redirectUrl: String
    ) async throws -> PaymentData
}

public extension PaymentsRepositoryType {
    func startSmartPayPayment(
        transactionType: TransactionType,
        packageTypeId: Int,
        iccid: String?,
        loyaltyPointsAmount: Double?,
        redirectUrl: String
    ) async throws -> PaymentData {
        throw SdkError.networkError(statusCode: 501, message: "SmartPay is not implemented by this repository")
    }
}
