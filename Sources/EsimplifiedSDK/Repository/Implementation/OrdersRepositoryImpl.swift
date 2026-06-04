//
//  OrdersRepositoryImpl.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/06/04.
//

import Foundation

final class OrdersRepositoryImpl: OrdersRepositoryType {

    private let client: HTTPClient
    private let cache: SdkCache

    init(client: HTTPClient, cache: SdkCache) {
        self.client = client
        self.cache = cache
    }

    func fetchOrders(forceRefresh: Bool = false, withLoyaltyPoints: Bool, cacheTTL: TimeInterval = 600) async -> [Order] {
        let cacheKey = "orders_\(withLoyaltyPoints)"
        if !forceRefresh, let cached: [Order] = await cache.get(cacheKey) {
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
            await cache.set(cacheKey, value: orders, ttl: cacheTTL)
            return orders
        } catch {
            return await cache.getExpired(cacheKey) ?? []
        }
    }

    func fetchOrder(orderUUID: String, forceRefresh: Bool = false, cacheTTL: TimeInterval = 300) async throws -> OrderDetail {
        let cacheKey = "order_\(orderUUID)"
        if !forceRefresh, let cached: OrderDetail = await cache.get(cacheKey) {
            return cached
        }
        let parameters = [
            "include_base64_qr_code": "true",
            "show_esim_details": "true"
        ]
        let maxRetries = 5
        var lastError: Error?
        for attempt in 1...maxRetries {
            do {
                let order: OrderDetail = try await client.fetch(
                    endpoint: .customerOrders,
                    method: .GET,
                    parameters: parameters,
                    id: orderUUID
                )
                if order.orderStatus != "pending" || attempt == maxRetries {
                    await cache.set(cacheKey, value: order, ttl: cacheTTL)
                    return order
                }
                try? await Task.sleep(for: .seconds(1))
            } catch let error where error is SdkError && "\(error)".contains("decoding") {
                lastError = error
                if attempt == maxRetries { break }
                try? await Task.sleep(for: .milliseconds(1500))
            } catch {
                throw error
            }
        }
        if let lastError { throw lastError }
        throw SdkError.unknown(NSError(domain: "OrdersRepository", code: -1))
    }

    func trackedOrder(orderUUID: String) async {
        do {
            let _: TrackedOrderResponse = try await client.fetch(
                endpoint: .customerOrders,
                method: .POST,
                id: orderUUID
            )
        } catch {
            // silently fail
        }
    }

    func invalidateCache() async {
        await cache.removeWithPrefix("orders_")
        await cache.removeWithPrefix("order_")
    }
}
