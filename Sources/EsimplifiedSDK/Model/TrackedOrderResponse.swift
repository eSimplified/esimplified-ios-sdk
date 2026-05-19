//
//  TrackedOrderResponse.swift
//  EsimplifiedSDK
//

import Foundation

// MARK: Tracked Order Response

public struct TrackedOrderResponse: Codable {
    public var detail: String
    public var conversionTracked: Bool

    public enum CodingKeys: String, CodingKey {
        case detail
        case conversionTracked = "conversion_tracked"
    }

    public init(detail: String, conversionTracked: Bool) {
        self.detail = detail
        self.conversionTracked = conversionTracked
    }
}
