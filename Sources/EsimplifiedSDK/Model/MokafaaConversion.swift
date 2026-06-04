//
//  MokafaaConversion.swift
//  EsimplifiedSDK
//

import Foundation

/// Client-side Mokafaa point conversion helpers.
public enum MokafaaConversion {
    public static let pointsPerSAR: Int = 10

    public static func pointsEarned(forPriceSAR price: Decimal) -> Int {
        let raw = price * Decimal(pointsPerSAR)
        return NSDecimalNumber(decimal: raw).intValue
    }

    public static func sarValue(forPoints points: Int) -> Decimal {
        Decimal(points) / Decimal(pointsPerSAR)
    }
}
