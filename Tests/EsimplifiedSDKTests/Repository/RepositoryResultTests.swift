//
//  RepositoryResultTests.swift
//  EsimplifiedSDK
//

import Testing
import Foundation
@testable import EsimplifiedSDK

extension NetworkSuite {

    private func makeResultEnv() -> (HTTPClient, SdkCache) {
        let config = SdkConfig(
            environment: .staging,
            clientName: "acme",
            clientId: "id",
            clientSecret: "secret"
        )
        let session = RecordingSessionProvider(
            initial: .authenticated(accessToken: "a", refreshToken: "r",
                                    expiresAt: Date().addingTimeInterval(3600))
        )
        let client = HTTPClient(config: config, sessionProvider: session, session: MockSession.make())
        return (client, SdkCache())
    }

    // MARK: Success

    @Test("A fresh fetch reports no failure and is not stale")
    func freshFetchReportsSuccess() async {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(
            json: #"""
            {"count":1,"next":null,"previous":null,"results":[
              {"country_name":"Andorra","country_name_slug":"andorra","country_code":"AD",
               "country_flag":"🇦🇩","country_flag_css":"ad","is_region":false}
            ]}
            """#
        )

        let (client, cache) = makeResultEnv()
        let repo = CountriesRepositoryImpl(client: client, cache: cache)

        let result = await repo.fetchAllCountriesResult()

        #expect(result.value.count == 1)
        #expect(result.didFail == false)
        #expect(result.isStale == false)
        #expect(result.failure == nil)
    }

    // MARK: Failure With Cache — scenario 3

    @Test("A failed refresh still returns expired cache, flagged stale, with the failure")
    func failedRefreshKeepsCacheAndReportsFailure() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = { _ in throw URLError(.notConnectedToInternet) }

        let (client, cache) = makeResultEnv()
        await cache.set("countries_all", value: [Country(countryName: "Cached")], ttl: 0.01)
        try await Task.sleep(nanoseconds: 50_000_000)

        let repo = CountriesRepositoryImpl(client: client, cache: cache)
        let result = await repo.fetchAllCountriesResult()

        #expect(result.value.count == 1)
        #expect(result.value.first?.countryName == "Cached")
        #expect(result.isStale)
        #expect(result.didFail)
        #expect(result.isOffline)
    }

    // MARK: Failure Without Cache — scenario 4

    @Test("A failed refresh with no cache returns empty AND the failure")
    func failedRefreshWithoutCacheReportsFailure() async {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(
            statusCode: 500, json: #"{"detail":"upstream exploded"}"#
        )

        let (client, cache) = makeResultEnv()
        let repo = CountriesRepositoryImpl(client: client, cache: cache)

        let result = await repo.fetchAllCountriesResult()

        #expect(result.value.isEmpty)
        #expect(result.didFail)
        #expect(result.isOffline == false)
        #expect(result.isStale == false)
        #expect(result.failure?.errorDescription == "upstream exploded")
    }

    // MARK: The Old Signature Still Behaves Exactly As Before

    @Test("fetchAllCountries returns the result's value, unchanged behaviour")
    func legacySignatureReturnsValue() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = { _ in throw URLError(.notConnectedToInternet) }

        let (client, cache) = makeResultEnv()
        await cache.set("countries_all", value: [Country(countryName: "Cached")], ttl: 0.01)
        try await Task.sleep(nanoseconds: 50_000_000)

        let repo = CountriesRepositoryImpl(client: client, cache: cache)

        #expect(await repo.fetchAllCountries().first?.countryName == "Cached")
    }

    // MARK: Valid Cache Short-Circuits

    @Test("A valid cache entry is returned without a request")
    func validCacheSkipsTheNetwork() async {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: #"{"count":0,"results":[]}"#)

        let (client, cache) = makeResultEnv()
        await cache.set("countries_all", value: [Country(countryName: "Cached")], ttl: 600)

        let repo = CountriesRepositoryImpl(client: client, cache: cache)
        let result = await repo.fetchAllCountriesResult()

        #expect(result.value.first?.countryName == "Cached")
        #expect(result.didFail == false)
        #expect(MockURLProtocol.capturedRequests.isEmpty)
    }

    // MARK: Esims / Orders / Packages Carry The Same Contract

    @Test("Esims: a failed fetch reports the failure instead of a silent empty list")
    func esimsReportFailure() async {
        MockURLProtocol.reset()
        MockURLProtocol.handler = { _ in throw URLError(.notConnectedToInternet) }

        let (client, cache) = makeResultEnv()
        let repo = EsimsRepositoryImpl(client: client, cache: cache)

        let result = await repo.fetchEsimsResult(archivedEsims: false)

        #expect(result.value.isEmpty)
        #expect(result.isOffline)
    }

    @Test("Orders: a failed fetch reports the failure instead of a silent empty list")
    func ordersReportFailure() async {
        MockURLProtocol.reset()
        MockURLProtocol.handler = { _ in throw URLError(.notConnectedToInternet) }

        let (client, cache) = makeResultEnv()
        let repo = OrdersRepositoryImpl(client: client, cache: cache)

        let result = await repo.fetchOrdersResult(withLoyaltyPoints: false)

        #expect(result.value.isEmpty)
        #expect(result.isOffline)
    }

    @Test("Packages: a failed country fetch reports the failure")
    func packagesReportFailure() async {
        MockURLProtocol.reset()
        MockURLProtocol.handler = { _ in throw URLError(.notConnectedToInternet) }

        let (client, cache) = makeResultEnv()
        let repo = PackagesRepositoryImpl(client: client, cache: cache)

        let result = await repo.fetchPackagesForCountryResult(
            countryCode: "AD", countryNameSlug: "andorra"
        )

        #expect(result.value == nil)
        #expect(result.isOffline)
    }
}

// MARK: - Throwing Mutations

extension NetworkSuite {

    private func makeEsimsRepo() -> EsimsRepositoryImpl {
        let config = SdkConfig(environment: .staging, clientName: "acme",
                               clientId: "id", clientSecret: "secret")
        let session = RecordingSessionProvider(
            initial: .authenticated(accessToken: "a", refreshToken: "r",
                                    expiresAt: Date().addingTimeInterval(3600))
        )
        let client = HTTPClient(config: config, sessionProvider: session, session: MockSession.make())
        return EsimsRepositoryImpl(client: client, cache: SdkCache())
    }

    @Test("A rename that the server accepts does not throw")
    func renameSucceeds() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(
            json: #"{"message":"eSIM updated successfully"}"#
        )

        try await makeEsimsRepo().updateEsimNameOrThrow(customName: "Kieran's phone", iccid: "123")
    }

    @Test("An offline rename throws noInternetConnection, not a bare false")
    func renameOfflineThrowsOffline() async {
        MockURLProtocol.reset()
        MockURLProtocol.handler = { _ in throw URLError(.notConnectedToInternet) }

        do {
            try await makeEsimsRepo().updateEsimNameOrThrow(customName: "nope", iccid: "123")
            Issue.record("Expected a throw")
        } catch {
            #expect((error as? SdkError)?.isOffline == true)
        }
    }

    @Test("A 2xx with an unexpected message throws a server error, not offline")
    func renameUnexpectedMessageThrowsServerError() async {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: #"{"message":"nope"}"#)

        do {
            try await makeEsimsRepo().updateEsimNameOrThrow(customName: "nope", iccid: "123")
            Issue.record("Expected a throw")
        } catch {
            let sdkError = error as? SdkError
            #expect(sdkError?.isOffline == false)
            #expect(sdkError?.errorDescription == "Server error: nope")
        }
    }

    @Test("The Bool signature still reports false on failure, unchanged behaviour")
    func boolSignaturePreserved() async {
        MockURLProtocol.reset()
        MockURLProtocol.handler = { _ in throw URLError(.notConnectedToInternet) }

        #expect(await makeEsimsRepo().updateEsimName(customName: "nope", iccid: "123") == false)
    }

    @Test("Set-primary surfaces the server's own message")
    func setPrimarySurfacesServerMessage() async {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(
            statusCode: 422, json: #"{"detail":"This eSIM is not universal"}"#
        )

        do {
            try await makeEsimsRepo().updateEsimPrimaryStatusOrThrow(status: true, iccid: "123")
            Issue.record("Expected a throw")
        } catch {
            #expect((error as? SdkError)?.errorDescription == "This eSIM is not universal")
        }
    }
}
