//
//  FaqAndSupportRepositoryType.swift
//  EsimplifiedSDK
//

import Foundation

/// Published copy the app displays but does not own: FAQs today; privacy policy, terms and support
/// content as they land. Named for the whole job so those do not each need a new repository.
public protocol FaqAndSupportRepositoryType {

    /// FAQs written for one destination — `faqs/destinations/{countryNameSlug}`.
    ///
    /// Returns an EMPTY array when the destination has none, which callers must render as "no FAQ
    /// section" rather than falling back to generic copy: showing another destination's answers
    /// under this one is worse than showing nothing (owner, 2026-09-01).
    func fetchDestinationFaqs(countryNameSlug: String, forceRefresh: Bool, cacheTTL: TimeInterval) async -> [Faq]

    /// Cache-first read that also reports why a refresh failed. See `RepositoryResult`.
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
