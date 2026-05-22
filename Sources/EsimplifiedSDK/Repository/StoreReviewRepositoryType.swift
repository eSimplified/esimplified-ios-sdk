//
//  StoreReviewRepositoryType.swift
//  EsimplifiedSDK
//

import Foundation

public protocol StoreReviewRepositoryType {
    func fetchStoreReview(cacheTTL: TimeInterval) async throws -> StoreReviewResponse
}
