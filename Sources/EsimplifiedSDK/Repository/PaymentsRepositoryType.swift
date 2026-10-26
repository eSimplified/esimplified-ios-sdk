//
//  PaymentsRepositoryType.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/06/04.
//

import Foundation

public protocol PaymentsRepositoryType {
    func fetchPayment(transactionType: TransactionType, packageTypeId: Int, iccid: String?, autoTopUp: Bool, savePaymentDetail: Bool, loyaltyPointsAmount: Double?) async throws -> PaymentData
    func sendKredsQuote(packageTypeId: Int, loyaltyPointsAmount: Double) async throws -> KredsQuoteResponse
    func fetchPaymentMethods() async throws -> [SavedPaymentMethod]
    func fetchPaymentMethods(eligibleFor discountCode: String) async throws -> [SavedPaymentMethod]
    func deletePaymentMethod(_ paymentMethodID: String) async throws
    func createPaymentMethodSetupIntent() async throws -> PaymentMethodSetupIntent
    func verifyPaymentMethod(_ paymentMethodID: String, discountCode: String) async throws -> SavedPaymentMethod
    func payWithStoredPaymentMethod(_ paymentMethodID: String, transactionType: TransactionType, packageTypeId: Int, iccid: String?, discountCode: String?) async throws -> PaymentData
}

public extension PaymentsRepositoryType {
    func payWithStoredPaymentMethod(_ paymentMethodID: String, transactionType: TransactionType, packageTypeId: Int, iccid: String?) async throws -> PaymentData {
        try await payWithStoredPaymentMethod(
            paymentMethodID,
            transactionType: transactionType,
            packageTypeId: packageTypeId,
            iccid: iccid,
            discountCode: nil
        )
    }
}
