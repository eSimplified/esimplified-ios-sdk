//
//  FaqAndSupportRepositoryType.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/09/01.
//

import Foundation

public protocol FaqAndSupportRepositoryType {

    // MARK: Destination FAQs

    func fetchDestinationFaqs(countryNameSlug: String, forceRefresh: Bool, cacheTTL: TimeInterval) async -> [Faq]

    func fetchDestinationFaqsResult(countryNameSlug: String, forceRefresh: Bool, cacheTTL: TimeInterval) async -> RepositoryResult<[Faq]>

    // MARK: Terms

    func fetchTerms(language: String, forceRefresh: Bool, cacheTTL: TimeInterval) async -> ContentDocument?

    func fetchTermsResult(language: String, forceRefresh: Bool, cacheTTL: TimeInterval) async -> RepositoryResult<ContentDocument?>

    // MARK: Privacy

    func fetchPrivacy(language: String, forceRefresh: Bool, cacheTTL: TimeInterval) async -> ContentDocument?

    func fetchPrivacyResult(language: String, forceRefresh: Bool, cacheTTL: TimeInterval) async -> RepositoryResult<ContentDocument?>

    // MARK: FAQs

    func fetchFaqs(language: String, forceRefresh: Bool, cacheTTL: TimeInterval) async -> ContentDocument?

    func fetchFaqsResult(language: String, forceRefresh: Bool, cacheTTL: TimeInterval) async -> RepositoryResult<ContentDocument?>

    func invalidateCache() async
}

public extension FaqAndSupportRepositoryType {

    func fetchDestinationFaqs(countryNameSlug: String, forceRefresh: Bool = false) async -> [Faq] {
        await fetchDestinationFaqs(countryNameSlug: countryNameSlug, forceRefresh: forceRefresh, cacheTTL: 86400)
    }

    func fetchDestinationFaqsResult(countryNameSlug: String, forceRefresh: Bool = false) async -> RepositoryResult<[Faq]> {
        await fetchDestinationFaqsResult(countryNameSlug: countryNameSlug, forceRefresh: forceRefresh, cacheTTL: 86400)
    }

    func fetchTerms(language: String, forceRefresh: Bool = false) async -> ContentDocument? {
        await fetchTerms(language: language, forceRefresh: forceRefresh, cacheTTL: 86400)
    }

    func fetchTermsResult(language: String, forceRefresh: Bool = false) async -> RepositoryResult<ContentDocument?> {
        await fetchTermsResult(language: language, forceRefresh: forceRefresh, cacheTTL: 86400)
    }

    func fetchPrivacy(language: String, forceRefresh: Bool = false) async -> ContentDocument? {
        await fetchPrivacy(language: language, forceRefresh: forceRefresh, cacheTTL: 86400)
    }

    func fetchPrivacyResult(language: String, forceRefresh: Bool = false) async -> RepositoryResult<ContentDocument?> {
        await fetchPrivacyResult(language: language, forceRefresh: forceRefresh, cacheTTL: 86400)
    }

    func fetchFaqs(language: String, forceRefresh: Bool = false) async -> ContentDocument? {
        await fetchFaqs(language: language, forceRefresh: forceRefresh, cacheTTL: 86400)
    }

    func fetchFaqsResult(language: String, forceRefresh: Bool = false) async -> RepositoryResult<ContentDocument?> {
        await fetchFaqsResult(language: language, forceRefresh: forceRefresh, cacheTTL: 86400)
    }
}
