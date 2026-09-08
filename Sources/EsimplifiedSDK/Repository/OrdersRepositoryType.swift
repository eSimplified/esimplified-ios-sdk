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

    func fetchOrdersResult(forceRefresh: Bool, withLoyaltyPoints: Bool, cacheTTL: TimeInterval) async -> RepositoryResult<[Order]>

    func fetchOrdersPageResult(
        limit: Int,
        offset: Int,
        withLoyaltyPoints: Bool,
        forceRefresh: Bool,
        cacheTTL: TimeInterval
    ) async -> RepositoryResult<OrdersPage>

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

public extension OrdersRepositoryType {

    func fetchInvoice(orderUUID: String) async throws -> Data {
        throw SdkError.networkError(statusCode: 501, message: "Invoice download is not implemented by this repository")
    }

    func fetchOrdersResult(forceRefresh: Bool, withLoyaltyPoints: Bool, cacheTTL: TimeInterval) async -> RepositoryResult<[Order]> {
        RepositoryResult(value: await fetchOrders(forceRefresh: forceRefresh, withLoyaltyPoints: withLoyaltyPoints, cacheTTL: cacheTTL))
    }

    func fetchOrdersResult(forceRefresh: Bool = false, withLoyaltyPoints: Bool) async -> RepositoryResult<[Order]> {
        await fetchOrdersResult(forceRefresh: forceRefresh, withLoyaltyPoints: withLoyaltyPoints, cacheTTL: 600)
    }

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

public struct OrdersPage: Codable {

    public let orders: [Order]
    public let totalCount: Int
    public let hasMore: Bool

    public init(orders: [Order], totalCount: Int, hasMore: Bool) {
        self.orders = orders
        self.totalCount = totalCount
        self.hasMore = hasMore
    }
}
