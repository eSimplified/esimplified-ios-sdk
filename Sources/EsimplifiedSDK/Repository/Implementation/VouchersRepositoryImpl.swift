//
//  VouchersRepositoryImpl.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/06/04.
//

import Foundation

final class VouchersRepositoryImpl: VouchersRepositoryType {

    private let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }

    func redeemVoucher(code: String) async throws -> VoucherRedeemResponse {
        let request = VoucherRedeemRequest(voucherCode: code)
        return try await client.fetch(
            endpoint: .redeemVoucher,
            method: .POST,
            body: request
        )
    }

    func previewGiftCard(pin: String) async throws -> GiftCardPreviewResponse {
        try await client.fetch(
            endpoint: .giftCardPreview,
            method: .POST,
            body: GiftCardPreviewRequest(pin: pin),
            requiresAuth: false
        )
    }

    func redeemGiftCard(request: GiftCardRedeemRequest) async throws -> GiftCardRedeemResponse {
        try await client.fetch(
            endpoint: .giftCardRedeem,
            method: .POST,
            body: request,
            requiresAuth: false
        )
    }
}
