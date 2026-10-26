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
    func awaitSettlement(
        orderUUID: String,
        interval: Duration,
        timeout: Duration,
        sleep: @Sendable (Duration) async throws -> Void
    ) async -> OrderSettlement
}

public extension OrdersRepositoryType {
    func fetchOrder(orderUUID: String, forceRefresh: Bool = false) async throws -> OrderDetail {
        try await fetchOrder(orderUUID: orderUUID, forceRefresh: forceRefresh, cacheTTL: 300)
    }
    func fetchOrders(forceRefresh: Bool = false, withLoyaltyPoints: Bool) async -> [Order] {
        await fetchOrders(forceRefresh: forceRefresh, withLoyaltyPoints: withLoyaltyPoints, cacheTTL: 600)
    }
    func awaitSettlement(
        orderUUID: String,
        interval: Duration,
        timeout: Duration,
        sleep: @Sendable (Duration) async throws -> Void
    ) async -> OrderSettlement {
        let deadline = Date().addingTimeInterval(timeout.timeInterval)
        var last: OrderDetail?
        while true {
            if let order = try? await fetchOrder(orderUUID: orderUUID, forceRefresh: true, cacheTTL: 0) {
                if order.isSettlementFailure { return .failed(order) }
                if order.isFulfilled { return .fulfilled(order) }
                last = order
            }
            if Date() >= deadline { return .pending(last) }
            do { try await sleep(interval) } catch { return .pending(last) }
        }
    }
    func awaitSettlement(orderUUID: String) async -> OrderSettlement {
        await awaitSettlement(
            orderUUID: orderUUID,
            interval: .seconds(3),
            timeout: .seconds(120),
            sleep: { try await Task.sleep(for: $0) }
        )
    }
}

private extension Duration {
    var timeInterval: TimeInterval {
        let parts = components
        return TimeInterval(parts.seconds) + TimeInterval(parts.attoseconds) / 1e18
    }
}
