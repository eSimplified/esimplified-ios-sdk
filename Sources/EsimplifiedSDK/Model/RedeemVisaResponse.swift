//
//  RedeemVisaResponse.swift
//  EsimplifiedSDK
//

import Foundation

// MARK: Redeem Visa Response

public struct RedeemVisaResponse: Codable {
    public var redeemed: Bool? = false
    public var detail: String? = ""
    public var redirectURL: String? = ""

    public enum CodingKeys: String, CodingKey {
        case redeemed, detail
        case redirectURL = "redirect_url"
    }

    public init(redeemed: Bool? = false, detail: String? = "", redirectURL: String? = "") {
        self.redeemed = redeemed
        self.detail = detail
        self.redirectURL = redirectURL
    }
}
