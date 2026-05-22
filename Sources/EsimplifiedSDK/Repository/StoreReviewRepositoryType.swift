//
//  StoreReviewRepositoryType.swift
//  EsimplifiedSDK
//

import Foundation

public protocol StoreReviewRepositoryType {
    func fetchStoreReview(cacheTTL: TimeInterval) async throws -> StoreReviewResponse
}

public extension StoreReviewRepositoryType {
    func fetchStoreReview() async throws -> StoreReviewResponse {
        try await fetchStoreReview(cacheTTL: 86400)
    }
}
