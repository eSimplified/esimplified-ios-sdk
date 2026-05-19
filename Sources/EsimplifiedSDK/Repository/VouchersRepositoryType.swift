//
//  VouchersRepositoryType.swift
//  EsimplifiedSDK
//

import Foundation

public protocol VouchersRepositoryType {
    func redeemVoucher(code: String) async throws -> VoucherRedeemResponse
}
