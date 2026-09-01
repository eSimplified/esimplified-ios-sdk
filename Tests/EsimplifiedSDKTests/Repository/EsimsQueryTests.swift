//
//  EsimsQueryTests.swift
//  EsimplifiedSDK
//

import Testing
import Foundation
@testable import EsimplifiedSDK

extension NetworkSuite {

    private func makeEsimsEnv() -> (HTTPClient, SdkCache) {
        let config = SdkConfig(
            environment: .staging,
            clientName: "acme",
            clientId: "id",
            clientSecret: "secret"
        )
        let session = RecordingSessionProvider(
            initial: .authenticated(
                accessToken: "a",
                refreshToken: "r",
                expiresAt: Date().addingTimeInterval(3600)
            )
        )
        let client = HTTPClient(config: config, sessionProvider: session, session: MockSession.make())
        return (client, SdkCache())
    }

    private func esimsQuery() -> [String: String] {
        guard let url = MockURLProtocol.capturedRequests.first?.url,
              let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems else {
            return [:]
        }
        return Dictionary(items.compactMap { item in
            item.value.map { (item.name, $0) }
        }, uniquingKeysWith: { first, _ in first })
    }

    @Test("eSIMs: the default asks for legacy too, so nothing vanishes from a customer's list")
    func esimsDefaultIncludesLegacy() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: #"{"esims": []}"#)
        let (client, cache) = makeEsimsEnv()
        let repo = EsimsRepositoryImpl(client: client, cache: cache)

        _ = await repo.fetchEsims(archivedEsims: false)

        #expect(esimsQuery()["show_legacy"] == "true")
    }

    @Test("eSIMs: universal-only sends show_legacy=false explicitly")
    func esimsUniversalOnlySendsFalse() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: #"{"esims": []}"#)
        let (client, cache) = makeEsimsEnv()
        let repo = EsimsRepositoryImpl(client: client, cache: cache)

        _ = await repo.fetchEsims(archivedEsims: false, showLegacy: false)

        #expect(esimsQuery()["show_legacy"] == "false")
    }

    @Test("eSIMs: is_primary is sent when asked for")
    func esimsIsPrimarySent() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: #"{"esims": []}"#)
        let (client, cache) = makeEsimsEnv()
        let repo = EsimsRepositoryImpl(client: client, cache: cache)

        _ = await repo.fetchEsims(archivedEsims: false, isPrimary: true)

        #expect(esimsQuery()["is_primary"] == "true")
    }

    @Test("eSIMs: is_primary is omitted unless asked for")
    func esimsIsPrimaryOmittedByDefault() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: #"{"esims": []}"#)
        let (client, cache) = makeEsimsEnv()
        let repo = EsimsRepositoryImpl(client: client, cache: cache)

        _ = await repo.fetchEsims(archivedEsims: false)

        #expect(esimsQuery()["is_primary"] == nil)
    }

    @Test("eSIMs: asks for a high limit so a long list is not silently truncated")
    func esimsAsksForAHighLimit() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: #"{"esims": []}"#)
        let (client, cache) = makeEsimsEnv()
        let repo = EsimsRepositoryImpl(client: client, cache: cache)

        _ = await repo.fetchEsims(archivedEsims: false)

        #expect(esimsQuery()["limit"] == "1000")
    }

    @Test("eSIMs: each distinct query caches separately")
    func esimsDistinctQueriesCacheSeparately() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: #"{"esims": []}"#)
        let (client, cache) = makeEsimsEnv()
        let repo = EsimsRepositoryImpl(client: client, cache: cache)

        _ = await repo.fetchEsims(archivedEsims: false)
        _ = await repo.fetchEsims(archivedEsims: false, showLegacy: false)
        _ = await repo.fetchEsims(archivedEsims: false, isPrimary: true)

        #expect(MockURLProtocol.capturedRequests.count == 3)
    }
}
