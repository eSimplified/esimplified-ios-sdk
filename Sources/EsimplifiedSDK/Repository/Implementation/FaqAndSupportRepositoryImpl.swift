//
//  FaqAndSupportRepositoryImpl.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/09/01.
//

import Foundation

final class FaqAndSupportRepositoryImpl: FaqAndSupportRepositoryType {

    private let client: HTTPClient
    private let cache: SdkCache

    private static let cachePrefixes = ["faqs_", "terms_", "privacy_", "support_"]

    init(client: HTTPClient, cache: SdkCache) {
        self.client = client
        self.cache = cache
    }

    // MARK: Destination FAQs

    func fetchDestinationFaqsResult(
        countryNameSlug: String,
        forceRefresh: Bool = false,
        cacheTTL: TimeInterval = 86400
    ) async -> RepositoryResult<[Faq]> {
        let cacheKey = "faqs_destination_\(countryNameSlug)"
        if !forceRefresh, let cached: [Faq] = await cache.get(cacheKey) {
            return RepositoryResult(value: cached)
        }
        do {
            let response: DestinationFaqResponse = try await client.fetch(
                endpoint: .destinationFaqs,
                method: .GET,
                id: countryNameSlug,
                requiresAuth: false
            )
            await cache.set(cacheKey, value: response.faqs, ttl: cacheTTL)
            return RepositoryResult(value: response.faqs)
        } catch {
            let failure = error as? SdkError ?? .unknown(error)
            let expired: [Faq] = await cache.getExpired(cacheKey) ?? []
            return RepositoryResult(value: expired, isStale: !expired.isEmpty, failure: failure)
        }
    }

    func fetchDestinationFaqs(
        countryNameSlug: String,
        forceRefresh: Bool = false,
        cacheTTL: TimeInterval = 86400
    ) async -> [Faq] {
        await fetchDestinationFaqsResult(
            countryNameSlug: countryNameSlug,
            forceRefresh: forceRefresh,
            cacheTTL: cacheTTL
        ).value
    }

    // MARK: Help Centre

    func fetchSupportSectionsResult(
        language: String,
        forceRefresh: Bool = false,
        cacheTTL: TimeInterval = 86400
    ) async -> RepositoryResult<[SupportSection]> {
        let cacheKey = "faqs_general_\(language)"
        if !forceRefresh, let cached: [SupportSection] = await cache.get(cacheKey) {
            return RepositoryResult(value: cached)
        }
        do {
            let envelope: ContentEnvelope<RawFaqsContent> = try await client.fetch(
                endpoint: .generalFaqs,
                method: .GET,
                requiresAuth: false
            )
            let sections = SupportContentParser.normalize(envelope.content)
            await cache.set(cacheKey, value: sections, ttl: cacheTTL)
            return RepositoryResult(value: sections)
        } catch {
            let failure = error as? SdkError ?? .unknown(error)
            let expired: [SupportSection] = await cache.getExpired(cacheKey) ?? []
            return RepositoryResult(value: expired, isStale: !expired.isEmpty, failure: failure)
        }
    }

    func fetchSupportSections(
        language: String,
        forceRefresh: Bool = false,
        cacheTTL: TimeInterval = 86400
    ) async -> [SupportSection] {
        await fetchSupportSectionsResult(
            language: language,
            forceRefresh: forceRefresh,
            cacheTTL: cacheTTL
        ).value
    }

    // MARK: Support Labels

    func fetchSupportLabelsResult(
        language: String,
        forceRefresh: Bool = false,
        cacheTTL: TimeInterval = 86400
    ) async -> RepositoryResult<SupportLabels?> {
        let cacheKey = "support_labels_\(language)"
        if !forceRefresh, let cached: SupportLabels = await cache.get(cacheKey) {
            return RepositoryResult(value: cached)
        }
        do {
            let envelope: ContentEnvelope<SupportLabels> = try await client.fetch(
                endpoint: .support,
                method: .GET,
                requiresAuth: false
            )
            await cache.set(cacheKey, value: envelope.content, ttl: cacheTTL)
            return RepositoryResult(value: envelope.content)
        } catch {
            let failure = error as? SdkError ?? .unknown(error)
            let expired: SupportLabels? = await cache.getExpired(cacheKey)
            return RepositoryResult(value: expired, isStale: expired != nil, failure: failure)
        }
    }

    func fetchSupportLabels(
        language: String,
        forceRefresh: Bool = false,
        cacheTTL: TimeInterval = 86400
    ) async -> SupportLabels? {
        await fetchSupportLabelsResult(
            language: language,
            forceRefresh: forceRefresh,
            cacheTTL: cacheTTL
        ).value
    }

    // MARK: Terms

    func fetchTermsResult(
        language: String,
        forceRefresh: Bool = false,
        cacheTTL: TimeInterval = 86400
    ) async -> RepositoryResult<TermsDocument?> {
        let cacheKey = "terms_\(language)"
        if !forceRefresh, let cached: TermsDocument = await cache.get(cacheKey) {
            return RepositoryResult(value: cached)
        }
        do {
            let envelope: ContentEnvelope<RawLegalContent> = try await client.fetch(
                endpoint: .terms,
                method: .GET,
                requiresAuth: false
            )
            let document = LegalContentParser.termsDocument(from: envelope.content)
            await cache.set(cacheKey, value: document, ttl: cacheTTL)
            return RepositoryResult(value: document)
        } catch {
            let failure = error as? SdkError ?? .unknown(error)
            let expired: TermsDocument? = await cache.getExpired(cacheKey)
            return RepositoryResult(value: expired, isStale: expired != nil, failure: failure)
        }
    }

    func fetchTerms(
        language: String,
        forceRefresh: Bool = false,
        cacheTTL: TimeInterval = 86400
    ) async -> TermsDocument? {
        await fetchTermsResult(
            language: language,
            forceRefresh: forceRefresh,
            cacheTTL: cacheTTL
        ).value
    }

    // MARK: Privacy

    func fetchPrivacyResult(
        language: String,
        forceRefresh: Bool = false,
        cacheTTL: TimeInterval = 86400
    ) async -> RepositoryResult<PrivacyDocument?> {
        let cacheKey = "privacy_\(language)"
        if !forceRefresh, let cached: PrivacyDocument = await cache.get(cacheKey) {
            return RepositoryResult(value: cached)
        }
        do {
            let envelope: ContentEnvelope<RawLegalContent> = try await client.fetch(
                endpoint: .privacy,
                method: .GET,
                requiresAuth: false
            )
            let document = LegalContentParser.privacyDocument(from: envelope.content)
            await cache.set(cacheKey, value: document, ttl: cacheTTL)
            return RepositoryResult(value: document)
        } catch {
            let failure = error as? SdkError ?? .unknown(error)
            let expired: PrivacyDocument? = await cache.getExpired(cacheKey)
            return RepositoryResult(value: expired, isStale: expired != nil, failure: failure)
        }
    }

    func fetchPrivacy(
        language: String,
        forceRefresh: Bool = false,
        cacheTTL: TimeInterval = 86400
    ) async -> PrivacyDocument? {
        await fetchPrivacyResult(
            language: language,
            forceRefresh: forceRefresh,
            cacheTTL: cacheTTL
        ).value
    }

    // MARK: Cache

    func invalidateCache() async {
        for prefix in Self.cachePrefixes {
            await cache.removeWithPrefix(prefix)
        }
    }
}
