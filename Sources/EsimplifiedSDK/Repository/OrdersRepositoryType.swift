//
//  OrdersRepositoryType.swift
//  EsimplifiedSDK
//

import Foundation

public protocol OrdersRepositoryType {
    func fetchOrder(orderUUID: String, forceRefresh: Bool) async throws -> OrderDetail
    func fetchOrders(forceRefresh: Bool, withLoyaltyPoints: Bool) async -> [Order]
    func trackedOrder(orderUUID: String) async
}
