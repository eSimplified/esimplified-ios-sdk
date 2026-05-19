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

    enum CodingKeys: String, CodingKey {
        case detail
        case conversionTracked = "conversion_tracked"
    }
}
