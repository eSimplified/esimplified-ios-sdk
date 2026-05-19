//
//  VouchersRepositoryImpl.swift
//  EsimplifiedSDK
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
}
