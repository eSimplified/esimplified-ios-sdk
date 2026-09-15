//
//  ContentRepositoryTests.swift
//  EsimplifiedSDK
//  Created by Zivaiishe Kanengoni on 2026/09/09.
//

import Testing
import Foundation
@testable import EsimplifiedSDK

extension NetworkSuite {

    private static let unavailableJson = #"{"detail":"Content is temporarily unavailable. Please try again later."}"#
    private static let unavailableMessage = "Content is temporarily unavailable. Please try again later."

    /// The smallest valid document: one section carrying one paragraph.
    private static func contentJson(language: String = "en") -> String {
        """
        {"language":"\(language)","id":"doc","title":"Doc","description":null,
         "updatedAt":"Last updated: 28 April 2025","blocks":[],
         "children":[{"id":"one","title":"One","description":null,"updatedAt":null,
         "blocks":[{"type":"paragraph","text":"Body."}],"children":[]}]}
        """
    }

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

    private func contentHandler(language: String = "en") -> MockURLProtocol.Handler {
        MockSession.jsonResponse(json: Self.contentJson(language: language))
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

    @Test("Content: fetchTerms GETs /api/v2/terms/ and forwards accept-language")
    func termsRequest() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = contentHandler(language: "ar")

        let (repo, _) = makeContentRepo(language: "ar")
        let document = await repo.fetchTerms(language: "ar")

        assertGet(path: "/api/v2/terms/")
        assertAcceptLanguage("ar")
        #expect(document?.language == "ar")
        #expect(document?.children.count == 1)
        #expect(document?.title?.isEmpty == false)
    }

    @Test("Content: fetchPrivacy GETs /api/v2/privacy/ and forwards accept-language")
    func privacyRequest() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = contentHandler()

        let (repo, _) = makeContentRepo(language: "en")
        let document = await repo.fetchPrivacy(language: "en")

        assertGet(path: "/api/v2/privacy/")
        assertAcceptLanguage("en")
        #expect(document?.children.count == 1)
        #expect(document?.updatedAt == "Last updated: 28 April 2025")
    }

    @Test("Content: fetchFaqs GETs /api/v2/faqs/ and forwards accept-language")
    func faqsRequest() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = contentHandler()

        let (repo, _) = makeContentRepo(language: "en")
        let document = await repo.fetchFaqs(language: "en")

        assertGet(path: "/api/v2/faqs/")
        assertAcceptLanguage("en")
        #expect(document?.children.count == 1)
        #expect(document?.children.first?.blocks == [.paragraph("Body.")])
    }

    // MARK: Caching

    @Test("Content: second fetchFaqs call is served from cache")
    func faqsCacheHit() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = contentHandler()

        let (repo, cache) = makeContentRepo()
        _ = await repo.fetchFaqs(language: "en")
        let again = await repo.fetchFaqsResult(language: "en")

        #expect(MockURLProtocol.capturedRequests.count == 1)
        #expect(again.isStale == false)
        #expect(again.failure == nil)
        #expect(again.value?.children.count == 1)
        let cached: ContentDocument? = await cache.get("faqs_en")
        #expect(cached?.children.count == 1)
    }

    @Test("Content: forceRefresh refetches terms")
    func termsForceRefresh() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = contentHandler()

        let (repo, cache) = makeContentRepo()
        _ = await repo.fetchTerms(language: "en")
        _ = await repo.fetchTerms(language: "en")
        #expect(MockURLProtocol.capturedRequests.count == 1)

        _ = await repo.fetchTerms(language: "en", forceRefresh: true)
        #expect(MockURLProtocol.capturedRequests.count == 2)
        let cached: ContentDocument? = await cache.get("terms_en")
        #expect(cached?.children.count == 1)
    }

    @Test("Content: privacy is cached under its language key")
    func privacyCacheKey() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = contentHandler()

        let (repo, cache) = makeContentRepo()
        _ = await repo.fetchPrivacy(language: "en")

        let cached: ContentDocument? = await cache.get("privacy_en")
        #expect(cached?.children.count == 1)
        let other: ContentDocument? = await cache.get("privacy_ar")
        #expect(other == nil)
    }

    // MARK: Failure

    @Test("Content: 503 surfaces the detail message with no cache")
    func faqs503NoCache() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(statusCode: 503, json: Self.unavailableJson)

        let (repo, _) = makeContentRepo()
        let result = await repo.fetchFaqsResult(language: "en")

        #expect(result.value == nil)
        #expect(result.isStale == false)
        #expect(result.didFail)
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
        let stale = ContentDocument(language: "en", title: "Old")
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

    @Test("Content: 503 on privacy yields nil value and the failure")
    func privacy503() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(statusCode: 503, json: Self.unavailableJson)

        let (repo, _) = makeContentRepo()
        let privacy = await repo.fetchPrivacyResult(language: "en")

        #expect(privacy.value == nil)
        #expect(privacy.didFail)
        #expect(privacy.failure?.errorDescription == Self.unavailableMessage)
    }

    // MARK: Invalidation

    @Test("Content: invalidateCache clears faqs_, terms_ and privacy_ prefixes")
    func invalidateCacheClearsAllPrefixes() async throws {
        let (repo, cache) = makeContentRepo()
        let document = ContentDocument(language: "en")
        await cache.set("faqs_en", value: document, ttl: 60)
        await cache.set("faqs_destination_canada", value: [Faq](), ttl: 60)
        await cache.set("terms_en", value: document, ttl: 60)
        await cache.set("privacy_en", value: document, ttl: 60)
        await cache.set("theme_page_home", value: "untouched", ttl: 60)

        await repo.invalidateCache()

        let faqs: ContentDocument? = await cache.get("faqs_en")
        let destination: [Faq]? = await cache.get("faqs_destination_canada")
        let terms: ContentDocument? = await cache.get("terms_en")
        let privacy: ContentDocument? = await cache.get("privacy_en")
        let theme: String? = await cache.get("theme_page_home")
        #expect(faqs == nil)
        #expect(destination == nil)
        #expect(terms == nil)
        #expect(privacy == nil)
        #expect(theme == "untouched")
    }
}
