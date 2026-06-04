//
//  StoreReviewRepositoryType.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/06/04.
//

import Foundation

public protocol StoreReviewRepositoryType {
    func fetchStoreReview(cacheTTL: TimeInterval) async throws -> StoreReviewResponse
    func invalidateCache() async
}

public extension StoreReviewRepositoryType {
    func fetchStoreReview() async throws -> StoreReviewResponse {
        try await fetchStoreReview(cacheTTL: 86400)
    }
}
