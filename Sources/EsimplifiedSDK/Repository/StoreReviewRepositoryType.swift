//
//  StoreReviewRepositoryType.swift
//  EsimplifiedSDK
//

import Foundation

public protocol StoreReviewRepositoryType {
    func fetchStoreReview() async throws -> StoreReviewResponse
}
