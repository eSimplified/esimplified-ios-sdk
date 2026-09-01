//
//  OrdersRepositoryType.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/06/04.
//

import Foundation

public protocol OrdersRepositoryType {
    func fetchOrder(orderUUID: String, forceRefresh: Bool, cacheTTL: TimeInterval) async throws -> OrderDetail
    func fetchOrders(forceRefresh: Bool, withLoyaltyPoints: Bool, cacheTTL: TimeInterval) async -> [Order]
    func trackedOrder(orderUUID: String) async
    func invalidateCache() async

    /// Cache-first read that also reports why a refresh failed. See `RepositoryResult`.
    func fetchOrdersResult(forceRefresh: Bool, withLoyaltyPoints: Bool, cacheTTL: TimeInterval) async -> RepositoryResult<[Order]>

    /// The order's invoice as PDF bytes. Deliberately NOT cached — an invoice is fetched on demand,
    /// it is large relative to the JSON this cache holds, and a stale one is worse than none.
    func fetchInvoice(orderUUID: String) async throws -> Data

}

public extension OrdersRepositoryType {
    func fetchOrder(orderUUID: String, forceRefresh: Bool = false) async throws -> OrderDetail {
        try await fetchOrder(orderUUID: orderUUID, forceRefresh: forceRefresh, cacheTTL: 300)
    }
    func fetchOrders(forceRefresh: Bool = false, withLoyaltyPoints: Bool) async -> [Order] {
        await fetchOrders(forceRefresh: forceRefresh, withLoyaltyPoints: withLoyaltyPoints, cacheTTL: 600)
    }
}

// MARK: - Result Defaults

/// Defaults so existing conformers — the app's mock and its inline test stubs — keep compiling
/// without change. Only the real implementation overrides them.
public extension OrdersRepositoryType {

    /// Default so existing conformers keep compiling. Only the real implementation fetches.
    func fetchInvoice(orderUUID: String) async throws -> Data {
        throw SdkError.networkError(statusCode: 501, message: "Invoice download is not implemented by this repository")
    }

    func fetchOrdersResult(forceRefresh: Bool, withLoyaltyPoints: Bool, cacheTTL: TimeInterval) async -> RepositoryResult<[Order]> {
        RepositoryResult(value: await fetchOrders(forceRefresh: forceRefresh, withLoyaltyPoints: withLoyaltyPoints, cacheTTL: cacheTTL))
    }

    func fetchOrdersResult(forceRefresh: Bool = false, withLoyaltyPoints: Bool) async -> RepositoryResult<[Order]> {
        await fetchOrdersResult(forceRefresh: forceRefresh, withLoyaltyPoints: withLoyaltyPoints, cacheTTL: 600)
    }
}
