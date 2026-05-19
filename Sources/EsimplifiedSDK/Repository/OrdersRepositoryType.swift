//
//  OrdersRepositoryType.swift
//  EsimplifiedSDK
//

import Foundation

public protocol OrdersRepositoryType {
    func fetchOrders(withLoyaltyPoints: Bool) async throws -> [Order]
    func fetchOrder(orderUUID: String) async throws -> OrderDetail
    func trackOrder(orderUUID: String) async throws -> TrackedOrderResponse
}
