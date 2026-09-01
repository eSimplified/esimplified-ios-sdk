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

    /// One page of orders, with whether the service reported another after it.
    ///
    /// `customer/orders/` paginates at **25** when no `limit` is sent, and the app used to send
    /// none — an account with 325 orders showed the newest 25 and silently stopped. `next` in the
    /// response is the URL of the following page; this exposes that as `hasMore`.
    func fetchOrdersPageResult(
        limit: Int,
        offset: Int,
        withLoyaltyPoints: Bool,
        forceRefresh: Bool,
        cacheTTL: TimeInterval
    ) async -> RepositoryResult<OrdersPage>

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

    /// Default so existing conformers — the app's mocks and inline test stubs — keep compiling.
    /// Serves the unpaged read as a single complete page.
    func fetchOrdersPageResult(
        limit: Int,
        offset: Int,
        withLoyaltyPoints: Bool,
        forceRefresh: Bool,
        cacheTTL: TimeInterval
    ) async -> RepositoryResult<OrdersPage> {
        let result = await fetchOrdersResult(
            forceRefresh: forceRefresh,
            withLoyaltyPoints: withLoyaltyPoints,
            cacheTTL: cacheTTL
        )
        return RepositoryResult(
            value: OrdersPage(orders: result.value, totalCount: result.value.count, hasMore: false),
            isStale: result.isStale,
            failure: result.failure
        )
    }

    func fetchOrdersPageResult(
        limit: Int = 100,
        offset: Int = 0,
        withLoyaltyPoints: Bool
    ) async -> RepositoryResult<OrdersPage> {
        await fetchOrdersPageResult(
            limit: limit,
            offset: offset,
            withLoyaltyPoints: withLoyaltyPoints,
            forceRefresh: false,
            cacheTTL: 600
        )
    }
}

// MARK: - Orders Page

/// One page of `customer/orders/`.
public struct OrdersPage: Codable {

    public let orders: [Order]
    /// Every order the account has, not just this page — the response's `count`.
    public let totalCount: Int
    /// Whether the service reported a `next` page after this one.
    public let hasMore: Bool

    public init(orders: [Order], totalCount: Int, hasMore: Bool) {
        self.orders = orders
        self.totalCount = totalCount
        self.hasMore = hasMore
    }
}
