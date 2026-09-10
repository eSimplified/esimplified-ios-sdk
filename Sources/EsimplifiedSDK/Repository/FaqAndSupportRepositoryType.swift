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

    // MARK: Help centre (general FAQs)

    func fetchSupportSections(language: String, forceRefresh: Bool, cacheTTL: TimeInterval) async -> [SupportSection]

    func fetchSupportSectionsResult(language: String, forceRefresh: Bool, cacheTTL: TimeInterval) async -> RepositoryResult<[SupportSection]>

    // MARK: Support labels

    func fetchSupportLabels(language: String, forceRefresh: Bool, cacheTTL: TimeInterval) async -> SupportLabels?

    func fetchSupportLabelsResult(language: String, forceRefresh: Bool, cacheTTL: TimeInterval) async -> RepositoryResult<SupportLabels?>

    // MARK: Terms

    func fetchTerms(language: String, forceRefresh: Bool, cacheTTL: TimeInterval) async -> TermsDocument?

    func fetchTermsResult(language: String, forceRefresh: Bool, cacheTTL: TimeInterval) async -> RepositoryResult<TermsDocument?>

    // MARK: Privacy

    func fetchPrivacy(language: String, forceRefresh: Bool, cacheTTL: TimeInterval) async -> PrivacyDocument?

    func fetchPrivacyResult(language: String, forceRefresh: Bool, cacheTTL: TimeInterval) async -> RepositoryResult<PrivacyDocument?>

    func invalidateCache() async
}

public extension FaqAndSupportRepositoryType {

    func fetchDestinationFaqs(countryNameSlug: String, forceRefresh: Bool = false) async -> [Faq] {
        await fetchDestinationFaqs(countryNameSlug: countryNameSlug, forceRefresh: forceRefresh, cacheTTL: 86400)
    }

    func fetchDestinationFaqsResult(countryNameSlug: String, forceRefresh: Bool = false) async -> RepositoryResult<[Faq]> {
        await fetchDestinationFaqsResult(countryNameSlug: countryNameSlug, forceRefresh: forceRefresh, cacheTTL: 86400)
    }

    func fetchSupportSections(language: String, forceRefresh: Bool = false) async -> [SupportSection] {
        await fetchSupportSections(language: language, forceRefresh: forceRefresh, cacheTTL: 86400)
    }

    func fetchSupportSectionsResult(language: String, forceRefresh: Bool = false) async -> RepositoryResult<[SupportSection]> {
        await fetchSupportSectionsResult(language: language, forceRefresh: forceRefresh, cacheTTL: 86400)
    }

    func fetchSupportLabels(language: String, forceRefresh: Bool = false) async -> SupportLabels? {
        await fetchSupportLabels(language: language, forceRefresh: forceRefresh, cacheTTL: 86400)
    }

    func fetchSupportLabelsResult(language: String, forceRefresh: Bool = false) async -> RepositoryResult<SupportLabels?> {
        await fetchSupportLabelsResult(language: language, forceRefresh: forceRefresh, cacheTTL: 86400)
    }

    func fetchTerms(language: String, forceRefresh: Bool = false) async -> TermsDocument? {
        await fetchTerms(language: language, forceRefresh: forceRefresh, cacheTTL: 86400)
    }

    func fetchTermsResult(language: String, forceRefresh: Bool = false) async -> RepositoryResult<TermsDocument?> {
        await fetchTermsResult(language: language, forceRefresh: forceRefresh, cacheTTL: 86400)
    }

    func fetchPrivacy(language: String, forceRefresh: Bool = false) async -> PrivacyDocument? {
        await fetchPrivacy(language: language, forceRefresh: forceRefresh, cacheTTL: 86400)
    }

    func fetchPrivacyResult(language: String, forceRefresh: Bool = false) async -> RepositoryResult<PrivacyDocument?> {
        await fetchPrivacyResult(language: language, forceRefresh: forceRefresh, cacheTTL: 86400)
    }
}
