//
//  StoreReviewRepositoryImpl.swift
//  EsimplifiedSDK
//

import Foundation

final class StoreReviewRepositoryImpl: StoreReviewRepositoryType {

    private let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }

    func fetchStoreReview() async throws -> StoreReviewResponse {
        let parameters = ["type": "store_review"]
        return try await client.fetch(
            endpoint: .storeReview,
            method: .GET,
            parameters: parameters,
            requiresAuth: false
        )
    }
}
