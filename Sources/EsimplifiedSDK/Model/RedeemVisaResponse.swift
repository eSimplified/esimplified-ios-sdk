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

    public var orderUUID: String? {
        guard let redirectURL, !redirectURL.isEmpty else { return nil }
        if let id = URLComponents(string: redirectURL)?.queryItems?.first(where: { $0.name == "id" })?.value, !id.isEmpty {
            return id
        }
        guard redirectURL.contains("="), let last = redirectURL.split(separator: "=").last, !last.isEmpty else { return nil }
        return String(last)
    }

    enum CodingKeys: String, CodingKey {
        case redeemed, detail
        case redirectURL = "redirect_url"
    }
}
