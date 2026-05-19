//
//  VoucherRedeemResponse.swift
//  EsimplifiedSDK
//

import Foundation

// MARK: Voucher Redeem Request

public struct VoucherRedeemRequest: Codable {
    public let voucherCode: String

    public enum CodingKeys: String, CodingKey {
        case voucherCode = "voucher_code"
    }

    public init(voucherCode: String) {
        self.voucherCode = voucherCode
    }
}

// MARK: Voucher Redeem Response

public struct VoucherRedeemResponse: Codable {
    public let redeemed: Bool
    public let redirectUrl: String?

    public var orderUUID: String? {
        guard let url = redirectUrl else { return nil }
        let components = url.split(separator: "=")
        return components.count > 1 ? String(components[1]) : nil
    }

    public enum CodingKeys: String, CodingKey {
        case redeemed
        case redirectUrl = "redirect_url"
    }

    public init(redeemed: Bool, redirectUrl: String? = nil) {
        self.redeemed = redeemed
        self.redirectUrl = redirectUrl
    }
}
