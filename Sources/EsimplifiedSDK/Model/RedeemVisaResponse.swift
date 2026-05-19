//
//  RedeemVisaResponse.swift
//  KnowRoaming
//
//  Created by Kieran on 2025/02/17.
//

import Foundation

// MARK: Redeem Visa Response

public struct RedeemVisaResponse: Codable {
    public var redeemed: Bool? = false
    public var detail: String? = ""
    public var redirectURL: String? = ""

    public init(redeemed: Bool? = false, detail: String? = "", redirectURL: String? = "") {
        self.redeemed = redeemed
        self.detail = detail
        self.redirectURL = redirectURL
    }

    enum CodingKeys: String, CodingKey {
        case redeemed, detail
        case redirectURL = "redirect_url"
    }
}
