//
//  OrdersRepositoryType.swift
//  EsimplifiedSDK
//

import Foundation

public protocol OrdersRepositoryType {
    func fetchOrders(forceRefresh: Bool, withLoyaltyPoints: Bool) async throws -> [Order]
    func fetchOrder(orderUUID: String, forceRefresh: Bool) async throws -> OrderDetail
    func trackOrder(orderUUID: String) async throws
}

public extension OrdersRepositoryType {
    func fetchOrders(withLoyaltyPoints: Bool) async throws -> [Order] {
        try await fetchOrders(forceRefresh: false, withLoyaltyPoints: withLoyaltyPoints)
    }
    func fetchOrder(orderUUID: String) async throws -> OrderDetail {
        try await fetchOrder(orderUUID: orderUUID, forceRefresh: false)
    }
}
