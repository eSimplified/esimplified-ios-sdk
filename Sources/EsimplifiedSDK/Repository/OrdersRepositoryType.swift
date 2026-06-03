//
//  OrdersRepositoryType.swift
//  EsimplifiedSDK
//

import Foundation

public protocol OrdersRepositoryType {
    func fetchOrder(orderUUID: String, forceRefresh: Bool, cacheTTL: TimeInterval) async throws -> OrderDetail
    func fetchOrders(forceRefresh: Bool, withLoyaltyPoints: Bool, cacheTTL: TimeInterval) async -> [Order]
    func trackedOrder(orderUUID: String) async
    func invalidateCache() async
}

public extension OrdersRepositoryType {
    func fetchOrder(orderUUID: String, forceRefresh: Bool = false) async throws -> OrderDetail {
        try await fetchOrder(orderUUID: orderUUID, forceRefresh: forceRefresh, cacheTTL: 300)
    }
    func fetchOrders(forceRefresh: Bool = false, withLoyaltyPoints: Bool) async -> [Order] {
        await fetchOrders(forceRefresh: forceRefresh, withLoyaltyPoints: withLoyaltyPoints, cacheTTL: 600)
    }
}
