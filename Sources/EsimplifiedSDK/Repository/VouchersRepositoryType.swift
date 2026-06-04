//
//  VouchersRepositoryType.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/06/04.
//

import Foundation

public protocol VouchersRepositoryType {
    func redeemVoucher(code: String) async throws -> VoucherRedeemResponse
}
