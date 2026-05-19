//
//  OrdersRepositoryImpl.swift
//  EsimplifiedSDK
//

import Foundation

final class OrdersRepositoryImpl: OrdersRepositoryType {

    private let client: HTTPClient
    private let cache: SdkCache

    init(client: HTTPClient, cache: SdkCache) {
        self.client = client
        self.cache = cache
    }

    func fetchOrders(forceRefresh: Bool = false, withLoyaltyPoints: Bool) async -> [Order] {
        let cacheKey = "orders_\(withLoyaltyPoints)"
        if !forceRefresh, let cached: [Order] = cache.get(cacheKey) {
            return cached
        }
        let parameters: [String: String] = withLoyaltyPoints ? ["used_points": "true"] : [:]
        do {
            let response: OrdersResponse = try await client.fetch(
                endpoint: .customerOrders,
                method: .GET,
                parameters: parameters
            )
            let orders = response.orders
            cache.set(cacheKey, value: orders, ttl: 300)
            return orders
        } catch {
            return []
        }
    }

    func fetchOrder(orderUUID: String, forceRefresh: Bool = false) async throws -> OrderDetail {
        let cacheKey = "order_\(orderUUID)"
        if !forceRefresh, let cached: OrderDetail = cache.get(cacheKey) {
            return cached
        }
        let parameters = [
            "include_base64_qr_code": "true",
            "show_esim_details": "true"
        ]
        let order: OrderDetail = try await client.fetch(
            endpoint: .customerOrders,
            method: .GET,
            parameters: parameters,
            id: orderUUID
        )
        cache.set(cacheKey, value: order)
        return order
    }

    func trackedOrder(orderUUID: String) async {
        do {
            let _: TrackedOrderResponse = try await client.fetch(
                endpoint: .customerOrders,
                method: .POST,
                id: orderUUID
            )
        } catch {
            // silently fail like the app does
        }
    }
}
