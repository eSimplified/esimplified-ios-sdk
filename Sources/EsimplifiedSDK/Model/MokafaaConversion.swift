//
//  MokafaaConversion.swift
//  EsimplifiedSDK
//

import Foundation

/// Client-side Mokafaa point conversion helpers.
///
/// The backend does not return a per-package earn count. Conversion lives here so the SDK
/// and its consumers (app, tests) share a single source of truth.
///
/// **TBD:** confirm with product whether the earn rate equals the burn rate before locking
/// `pointsPerSAR`. Both are currently assumed to be `10 mokafaa points = 1 SAR`.
public enum MokafaaConversion {

    /// Number of mokafaa points equivalent to 1 SAR. Used for both earning and redeeming
    /// until product confirms otherwise.
    public static let pointsPerSAR: Int = 10

    /// Computes the mokafaa points a customer would earn for a purchase priced in SAR.
    /// Truncates fractional points (matches typical loyalty programs).
    public static func pointsEarned(forPriceSAR price: Decimal) -> Int {
        let raw = price * Decimal(pointsPerSAR)
        return NSDecimalNumber(decimal: raw).intValue
    }

    /// Computes the SAR value of a given mokafaa point amount.
    public static func sarValue(forPoints points: Int) -> Decimal {
        Decimal(points) / Decimal(pointsPerSAR)
    }
}
