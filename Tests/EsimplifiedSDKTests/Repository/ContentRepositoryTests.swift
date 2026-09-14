//
//  ContentRepositoryTests.swift
//  EsimplifiedSDK
//  Created by Zivaiishe Kanengoni on 2026/09/09.
//

import Testing
import Foundation
@testable import EsimplifiedSDK

extension NetworkSuite {

    private static let unavailableJson = #"{"detail":"FAQs are temporarily unavailable. Please try again later."}"#
    private static let unavailableMessage = "FAQs are temporarily unavailable. Please try again later."

    private func makeContentRepo(
        language: String = "en"
    ) -> (FaqAndSupportRepositoryImpl, SdkCache) {
        let config = SdkConfig(
            environment: .staging,
            clientName: "acme",
            clientId: "id",
            clientSecret: "secret",
            customHeadersProvider: { ["accept-language": language] }
        )
        let session = RecordingSessionProvider(
            initial: .authenticated(accessToken: "a", refreshToken: "r", expiresAt: Date().addingTimeInterval(3600))
        )
        let client = HTTPClient(config: config, sessionProvider: session, session: MockSession.make())
        let cache = SdkCache()
        return (FaqAndSupportRepositoryImpl(client: client, cache: cache), cache)
    }

    private func fixtureHandler(_ name: String) throws -> MockURLProtocol.Handler {
        let body = String(decoding: try Fixtures.data(name), as: UTF8.self)
        return MockSession.jsonResponse(json: body)
    }

    private func assertGet(path: String) {
        let request = MockURLProtocol.capturedRequests.first
        let urlString = request?.url?.absoluteString ?? ""
        #expect(request?.httpMethod == "GET")
        #expect(urlString.hasSuffix(path), "expected \(urlString) to end with \(path)")
        #expect(!urlString.contains("?"))
    }

    private func assertAcceptLanguage(_ language: String) {
        #expect(MockURLProtocol.capturedRequests.first?.value(forHTTPHeaderField: "accept-language") == language)
    }

    // MARK: Request shape

    @Test("Content: fetchSupportSections GETs /api/v2/faqs/ and forwards accept-language")
    func supportSectionsRequest() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = try fixtureHandler("faqs_en")

        let (repo, _) = makeContentRepo(language: "en")
        let sections = await repo.fetchSupportSections(language: "en")

        assertGet(path: "/api/v2/faqs/")
        assertAcceptLanguage("en")
        #expect(sections.count == 6)
        #expect(sections.flatMap(\.articles).count == 62)
    }

    @Test("Content: fetchTerms GETs /api/v2/terms/ and forwards accept-language")
    func termsRequest() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = try fixtureHandler("terms_ar")

        let (repo, _) = makeContentRepo(language: "ar")
        let document = await repo.fetchTerms(language: "ar")

        assertGet(path: "/api/v2/terms/")
        assertAcceptLanguage("ar")
        #expect(document?.sections.count == 9)
        #expect(document?.title.isEmpty == false)
    }

    @Test("Content: fetchPrivacy GETs /api/v2/privacy/ and forwards accept-language")
    func privacyRequest() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = try fixtureHandler("privacy_en")

        let (repo, _) = makeContentRepo(language: "en")
        let document = await repo.fetchPrivacy(language: "en")

        assertGet(path: "/api/v2/privacy/")
        assertAcceptLanguage("en")
        #expect(document?.sections.count == 14)
        #expect(document?.lastUpdated == "Last updated: 28 April 2025")
    }

    @Test("Content: fetchSupportLabels GETs /api/v2/support/ and forwards accept-language")
    func supportLabelsRequest() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = try fixtureHandler("support_en")

        let (repo, _) = makeContentRepo(language: "en")
        let labels = await repo.fetchSupportLabels(language: "en")

        assertGet(path: "/api/v2/support/")
        assertAcceptLanguage("en")
        #expect(labels?.hero?.searchPlaceholder != nil)
    }

    // MARK: Caching

    @Test("Content: second fetchSupportSections call is served from cache")
    func supportSectionsCacheHit() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = try fixtureHandler("faqs_en")

        let (repo, cache) = makeContentRepo()
        _ = await repo.fetchSupportSections(language: "en")
        let again = await repo.fetchSupportSectionsResult(language: "en")

        #expect(MockURLProtocol.capturedRequests.count == 1)
        #expect(again.isStale == false)
        #expect(again.failure == nil)
        let cached: [SupportSection]? = await cache.get("faqs_general_en")
        #expect(cached?.count == 6)
    }

    @Test("Content: forceRefresh refetches terms")
    func termsForceRefresh() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = try fixtureHandler("terms_en")

        let (repo, cache) = makeContentRepo()
        _ = await repo.fetchTerms(language: "en")
        _ = await repo.fetchTerms(language: "en")
        #expect(MockURLProtocol.capturedRequests.count == 1)

        _ = await repo.fetchTerms(language: "en", forceRefresh: true)
        #expect(MockURLProtocol.capturedRequests.count == 2)
        let cached: TermsDocument? = await cache.get("terms_en")
        #expect(cached?.sections.count == 9)
    }

    @Test("Content: privacy and labels are cached under their language keys")
    func privacyAndLabelsCacheKeys() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = try fixtureHandler("privacy_en")
        let (repo, cache) = makeContentRepo()
        _ = await repo.fetchPrivacy(language: "en")
        let privacy: PrivacyDocument? = await cache.get("privacy_en")
        #expect(privacy?.sections.count == 14)

        MockURLProtocol.handler = try fixtureHandler("support_en")
        _ = await repo.fetchSupportLabels(language: "en")
        let labels: SupportLabels? = await cache.get("support_labels_en")
        #expect(labels?.hero?.searchPlaceholder != nil)
        #expect(MockURLProtocol.capturedRequests.count == 2)
    }

    // MARK: Failure

    @Test("Content: 503 surfaces the detail message with no cache")
    func supportSections503NoCache() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(statusCode: 503, json: Self.unavailableJson)

        let (repo, _) = makeContentRepo()
        let result = await repo.fetchSupportSectionsResult(language: "en")

        #expect(result.value.isEmpty)
        #expect(result.isStale == false)
        guard case .networkError(let statusCode, let message)? = result.failure else {
            Issue.record("expected networkError, got \(String(describing: result.failure))")
            return
        }
        #expect(statusCode == 503)
        #expect(message == Self.unavailableMessage)
    }

    @Test("Content: 503 returns the expired cache as stale with the failure attached")
    func termsStaleFallback() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(statusCode: 503, json: Self.unavailableJson)

        let (repo, cache) = makeContentRepo()
        let stale = TermsDocument(title: "Old", tocLabel: "On this page", sections: [])
        await cache.set("terms_en", value: stale, ttl: 0.01)
        try? await Task.sleep(nanoseconds: 50_000_000)

        let result = await repo.fetchTermsResult(language: "en")
        #expect(result.value?.title == "Old")
        #expect(result.isStale)
        guard case .networkError(let statusCode, let message)? = result.failure else {
            Issue.record("expected networkError, got \(String(describing: result.failure))")
            return
        }
        #expect(statusCode == 503)
        #expect(message == Self.unavailableMessage)

        let plain = await repo.fetchTerms(language: "en")
        #expect(plain?.title == "Old")
    }

    @Test("Content: 503 on labels and privacy yields nil value and the failure")
    func labelsAndPrivacy503() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(statusCode: 503, json: Self.unavailableJson)

        let (repo, _) = makeContentRepo()
        let labels = await repo.fetchSupportLabelsResult(language: "en")
        let privacy = await repo.fetchPrivacyResult(language: "en")

        #expect(labels.value == nil)
        #expect(labels.didFail)
        #expect(privacy.value == nil)
        #expect(privacy.didFail)
        #expect(privacy.failure?.errorDescription == Self.unavailableMessage)
    }

    // MARK: Invalidation

    @Test("Content: invalidateCache clears faqs_, terms_, privacy_ and support_ prefixes")
    func invalidateCacheClearsAllPrefixes() async throws {
        let (repo, cache) = makeContentRepo()
        await cache.set("faqs_general_en", value: [SupportSection](), ttl: 60)
        await cache.set("faqs_destination_canada", value: [Faq](), ttl: 60)
        await cache.set("terms_en", value: TermsDocument(title: "", tocLabel: "", sections: []), ttl: 60)
        await cache.set("privacy_en", value: PrivacyDocument(title: "", tocLabel: "", sections: []), ttl: 60)
        await cache.set("support_labels_en", value: SupportLabels(), ttl: 60)
        await cache.set("theme_page_home", value: "untouched", ttl: 60)

        await repo.invalidateCache()

        let faqs: [SupportSection]? = await cache.get("faqs_general_en")
        let destination: [Faq]? = await cache.get("faqs_destination_canada")
        let terms: TermsDocument? = await cache.get("terms_en")
        let privacy: PrivacyDocument? = await cache.get("privacy_en")
        let labels: SupportLabels? = await cache.get("support_labels_en")
        let theme: String? = await cache.get("theme_page_home")
        #expect(faqs == nil)
        #expect(destination == nil)
        #expect(terms == nil)
        #expect(privacy == nil)
        #expect(labels == nil)
        #expect(theme == "untouched")
    }
}
