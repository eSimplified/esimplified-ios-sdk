//
//  LocalizationRepositoryTests.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/11/18.
//

import Testing
import Foundation
@testable import EsimplifiedSDK

extension NetworkSuite {

    private static let currenciesJson = #"""
    {"default_currency":"","currencies":[
      {"code":"AED","name":"United Arab Dirham","symbol":"AED"},
      {"code":"USD","name":"US Dollar","symbol":"$"}
    ]}
    """#

    private static let languagesJson = #"""
    {"default_language":"en","languages":[{"code":"en","name":"English"},{"code":"ar","name":"Arabic"}]}
    """#

    private func makeLocalizationRepo(
        initial: AuthState = .unauthenticated
    ) -> (LocalizationRepositoryImpl, SdkCache) {
        let config = SdkConfig(
            environment: .staging,
            clientName: "acme",
            clientId: "id",
            clientSecret: "secret"
        )
        let session = RecordingSessionProvider(initial: initial)
        let client = HTTPClient(config: config, sessionProvider: session, session: MockSession.make())
        let cache = SdkCache()
        return (LocalizationRepositoryImpl(client: client, cache: cache), cache)
    }

    private func localizationQuery() -> [URLQueryItem] {
        MockURLProtocol.capturedRequests.first?.url
            .flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false)?.queryItems } ?? []
    }

    // MARK: Request shape

    @Test("Localization: include currencies GETs /api/v2/localization/ with include=currencies")
    func localizationCurrenciesRequest() async {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: Self.currenciesJson)

        let (repo, _) = makeLocalizationRepo()
        let localization = await repo.fetchLocalization(include: .currencies)

        let request = MockURLProtocol.capturedRequests.first
        #expect(request?.httpMethod == "GET")
        #expect(request?.url?.absoluteString.contains("/api/v2/localization/?") == true)
        #expect(localizationQuery() == [URLQueryItem(name: "include", value: "currencies")])
        #expect(localization.currencies.map(\.code) == ["AED", "USD"])
        #expect(localization.currencies.last?.symbol == "$")
        #expect(localization.defaultCurrency == "")
        #expect(localization.languages.isEmpty)
        #expect(localization.defaultLanguage == nil)
    }

    @Test("Localization: include languages sends include=languages and decodes a response with no currencies")
    func localizationLanguagesRequest() async {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: Self.languagesJson)

        let (repo, _) = makeLocalizationRepo()
        let localization = await repo.fetchLocalization(include: .languages)

        #expect(localizationQuery() == [URLQueryItem(name: "include", value: "languages")])
        #expect(localization.languages.map(\.code) == ["en", "ar"])
        #expect(localization.defaultLanguage == "en")
        #expect(localization.currencies.isEmpty)
        #expect(localization.defaultCurrency == nil)
    }

    @Test("Localization: no include sends no query")
    func localizationFullRequest() async {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: Self.currenciesJson)

        let (repo, _) = makeLocalizationRepo()
        _ = await repo.fetchLocalization()

        let url = MockURLProtocol.capturedRequests.first?.url
        #expect(url?.absoluteString.hasSuffix("/api/v2/localization/") == true)
        #expect(url?.query == nil)
    }

    // MARK: Authorization

    @Test("Localization: a signed-out call sends the client's Basic credentials")
    func localizationSignedOutSendsBasic() async {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: Self.currenciesJson)

        let (repo, _) = makeLocalizationRepo()
        _ = await repo.fetchLocalization(include: .currencies)

        let authorization = MockURLProtocol.capturedRequests.first?.value(forHTTPHeaderField: "Authorization")
        #expect(authorization?.hasPrefix("Basic ") == true)
    }

    @Test("Localization: a signed-in call sends the customer's token, so the list can be per customer")
    func localizationSignedInSendsBearer() async {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: Self.currenciesJson)

        let (repo, _) = makeLocalizationRepo(
            initial: .authenticated(accessToken: "a", refreshToken: "r", expiresAt: Date().addingTimeInterval(3600))
        )
        _ = await repo.fetchLocalization(include: .currencies)

        let authorization = MockURLProtocol.capturedRequests.first?.value(forHTTPHeaderField: "Authorization")
        #expect(authorization == "Bearer a")
    }

    // MARK: Cache

    @Test("Localization: a warm cache skips the network, forceRefresh and invalidateCache do not")
    func localizationCache() async {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: Self.currenciesJson)

        let (repo, _) = makeLocalizationRepo()

        _ = await repo.fetchLocalization(include: .currencies)
        _ = await repo.fetchLocalization(include: .currencies)
        #expect(MockURLProtocol.capturedRequests.count == 1)

        _ = await repo.fetchLocalization(include: .currencies, forceRefresh: true)
        #expect(MockURLProtocol.capturedRequests.count == 2)

        await repo.invalidateCache()
        _ = await repo.fetchLocalization(include: .currencies)
        #expect(MockURLProtocol.capturedRequests.count == 3)
    }

    @Test("Localization: currencies and languages are cached under different keys")
    func localizationCacheKeys() async {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: Self.currenciesJson)

        let (repo, _) = makeLocalizationRepo()

        _ = await repo.fetchLocalization(include: .currencies)
        _ = await repo.fetchLocalization(include: .languages)

        #expect(MockURLProtocol.capturedRequests.count == 2)
    }

    // MARK: Failure

    @Test("Localization: a failed refresh returns the expired list, flagged stale, with the failure")
    func localizationFailureKeepsExpiredCache() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = { _ in throw URLError(.notConnectedToInternet) }

        let (repo, cache) = makeLocalizationRepo()
        await cache.set(
            "localization_currencies",
            value: Localization(currencies: [SupportedCurrency(code: "USD")]),
            ttl: 0.01
        )
        try await Task.sleep(nanoseconds: 50_000_000)

        let result = await repo.fetchLocalizationResult(include: .currencies)

        #expect(result.value.currencies.map(\.code) == ["USD"])
        #expect(result.isStale)
        #expect(result.didFail)
        #expect(result.isOffline)
    }

    @Test("Localization: a failure with nothing cached returns an empty localization and the failure")
    func localizationFailureWithoutCache() async {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(statusCode: 404, json: #"{"detail":"Not found."}"#)

        let (repo, _) = makeLocalizationRepo()
        let result = await repo.fetchLocalizationResult(include: .currencies)

        #expect(result.value.currencies.isEmpty)
        #expect(result.isStale == false)
        #expect(result.didFail)
    }
}
