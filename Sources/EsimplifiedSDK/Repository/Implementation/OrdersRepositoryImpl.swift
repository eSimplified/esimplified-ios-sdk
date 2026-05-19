//
//  OrdersRepositoryImpl.swift
//  EsimplifiedSDK
//

import Foundation

final class OrdersRepositoryImpl: OrdersRepositoryType {

    private let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }

    func fetchOrders(withLoyaltyPoints: Bool) async throws -> [Order] {
        let parameters: [String: String] = withLoyaltyPoints ? ["used_points": "true"] : [:]
        let response: OrdersResponse = try await client.fetch(
            endpoint: .customerOrders,
            method: .GET,
            parameters: parameters
        )
        return response.orders
    }

    func fetchOrder(orderUUID: String) async throws -> OrderDetail {
        let parameters = [
            "include_base64_qr_code": "true",
            "show_esim_details": "true"
        ]
        return try await client.fetch(
            endpoint: .customerOrders,
            method: .GET,
            parameters: parameters,
            id: orderUUID
        )
    }

    func trackOrder(orderUUID: String) async throws -> TrackedOrderResponse {
        try await client.fetch(
            endpoint: .customerOrders,
            method: .POST,
            id: orderUUID
        )
    }
}
