//
//  PaymentsRepositoryType.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/06/04.
//

import Foundation

public protocol PaymentsRepositoryType {
    func fetchPayment(transactionType: TransactionType, packageTypeId: Int, iccid: String?, autoTopUp: Bool, savePaymentDetail: Bool, loyaltyPointsAmount: Double?) async throws -> PaymentData
    func sendKredsQuote(packageTypeId: Int, loyaltyPointsAmount: Double) async throws -> KredsQuoteResponse
}
