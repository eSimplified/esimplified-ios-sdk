//
//  FaqAndSupportRepositoryType.swift
//  EsimplifiedSDK
//

import Foundation

public protocol FaqAndSupportRepositoryType {

    func fetchDestinationFaqs(countryNameSlug: String, forceRefresh: Bool, cacheTTL: TimeInterval) async -> [Faq]

    func fetchDestinationFaqsResult(countryNameSlug: String, forceRefresh: Bool, cacheTTL: TimeInterval) async -> RepositoryResult<[Faq]>

    func invalidateCache() async
}

public extension FaqAndSupportRepositoryType {

    func fetchDestinationFaqs(countryNameSlug: String, forceRefresh: Bool = false) async -> [Faq] {
        await fetchDestinationFaqs(countryNameSlug: countryNameSlug, forceRefresh: forceRefresh, cacheTTL: 86400)
    }

    func fetchDestinationFaqsResult(countryNameSlug: String, forceRefresh: Bool = false) async -> RepositoryResult<[Faq]> {
        await fetchDestinationFaqsResult(countryNameSlug: countryNameSlug, forceRefresh: forceRefresh, cacheTTL: 86400)
    }
}
