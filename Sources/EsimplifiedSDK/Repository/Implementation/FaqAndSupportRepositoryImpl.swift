//
//  FaqAndSupportRepositoryImpl.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/09/01.
//

import Foundation

final class FaqAndSupportRepositoryImpl: FaqAndSupportRepositoryType {

    private let client: HTTPClient
    private let cache: SdkCache

    private static let cachePrefixes = ["faqs_", "terms_", "privacy_"]

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

    // MARK: Terms

    func fetchTermsResult(
        language: String,
        forceRefresh: Bool = false,
        cacheTTL: TimeInterval = 86400
    ) async -> RepositoryResult<ContentDocument?> {
        await fetchDocumentResult(
            endpoint: .terms,
            cacheKey: "terms_\(language)",
            forceRefresh: forceRefresh,
            cacheTTL: cacheTTL
        )
    }

    func fetchTerms(
        language: String,
        forceRefresh: Bool = false,
        cacheTTL: TimeInterval = 86400
    ) async -> ContentDocument? {
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
    ) async -> RepositoryResult<ContentDocument?> {
        await fetchDocumentResult(
            endpoint: .privacy,
            cacheKey: "privacy_\(language)",
            forceRefresh: forceRefresh,
            cacheTTL: cacheTTL
        )
    }

    func fetchPrivacy(
        language: String,
        forceRefresh: Bool = false,
        cacheTTL: TimeInterval = 86400
    ) async -> ContentDocument? {
        await fetchPrivacyResult(
            language: language,
            forceRefresh: forceRefresh,
            cacheTTL: cacheTTL
        ).value
    }

    // MARK: FAQs

    func fetchFaqsResult(
        language: String,
        forceRefresh: Bool = false,
        cacheTTL: TimeInterval = 86400
    ) async -> RepositoryResult<ContentDocument?> {
        await fetchDocumentResult(
            endpoint: .generalFaqs,
            cacheKey: "faqs_\(language)",
            forceRefresh: forceRefresh,
            cacheTTL: cacheTTL
        )
    }

    func fetchFaqs(
        language: String,
        forceRefresh: Bool = false,
        cacheTTL: TimeInterval = 86400
    ) async -> ContentDocument? {
        await fetchFaqsResult(
            language: language,
            forceRefresh: forceRefresh,
            cacheTTL: cacheTTL
        ).value
    }

    // MARK: Content Document

    private func fetchDocumentResult(
        endpoint: Endpoints,
        cacheKey: String,
        forceRefresh: Bool,
        cacheTTL: TimeInterval
    ) async -> RepositoryResult<ContentDocument?> {
        if !forceRefresh, let cached: ContentDocument = await cache.get(cacheKey) {
            return RepositoryResult(value: cached)
        }
        do {
            let document: ContentDocument = try await client.fetch(
                endpoint: endpoint,
                method: .GET,
                requiresAuth: false
            )
            await cache.set(cacheKey, value: document, ttl: cacheTTL)
            return RepositoryResult(value: document)
        } catch {
            let failure = error as? SdkError ?? .unknown(error)
            let expired: ContentDocument? = await cache.getExpired(cacheKey)
            return RepositoryResult(value: expired, isStale: expired != nil, failure: failure)
        }
    }

    // MARK: Cache

    func invalidateCache() async {
        for prefix in Self.cachePrefixes {
            await cache.removeWithPrefix(prefix)
        }
    }
}
