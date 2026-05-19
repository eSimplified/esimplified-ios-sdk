//
//  VisaRewardResponse.swift
//  KnowRoaming
//
//  Created by Kieran on 2025/04/09.
//

import Foundation

// MARK: Visa Reward Response

public struct VisaRewardResponse: Codable, Hashable {
    public var created: Bool? = false
    public var token: String = ""
    public var iframeURL: String? = ""
    public var correlationId: String? = ""
    public var aliasId: String? = ""
    public var eligible: Bool? = false
    public var status: Int? = 0

    enum CodingKeys: String, CodingKey {
        case eligible, status, token
        case created = "created"
        case iframeURL = "iframe_url"
        case correlationId = "correlation_id"
        case aliasId = "alias_id"
    }
}
