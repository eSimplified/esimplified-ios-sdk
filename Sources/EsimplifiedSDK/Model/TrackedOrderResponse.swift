//
//  TrackedOrderResponse.swift
//  KnowRoaming
//
//  Created by Kieran on 2025/03/23.
//

import Foundation

// MARK: Tracked Order Response

public struct TrackedOrderResponse: Codable {
    public var detail: String
    public var conversionTracked: Bool

    public init(detail: String, conversionTracked: Bool) {
        self.detail = detail
        self.conversionTracked = conversionTracked
    }

    enum CodingKeys: String, CodingKey {
        case detail
        case conversionTracked = "conversion_tracked"
    }
}
