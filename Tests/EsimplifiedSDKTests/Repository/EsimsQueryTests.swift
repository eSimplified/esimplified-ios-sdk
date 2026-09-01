//
//  EsimsQueryTests.swift
//  EsimplifiedSDK
//

import Testing
import Foundation
@testable import EsimplifiedSDK

extension NetworkSuite {

    /// Local copy — `RepositoryTests`' version is `private` to that file.
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

    /// 🔴 The service changed on 2026-09-01: `GET /customer/esims/` now returns **universal eSIMs
    /// only**, and `?show_legacy=true` is required to get everything. Any screen listing a
    /// customer's plans MUST send it, or their legacy eSIMs silently vanish from the app.
    ///
    /// The default is therefore `showLegacy: true` — it preserves exactly what every existing
    /// caller already expects. Universal-only is opt-in, for callers that genuinely mean it.
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

    /// Filtering server-side is the point: the customer's whole eSIM list is what makes this
    /// endpoint slow (13s on a large account, measured on device 2026-09-01).
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

    /// 🔴 Different queries return different eSIMs. Sharing one cache key would let a
    /// universal-only or primary-only response satisfy a later request for the FULL list, silently
    /// hiding eSIMs the customer owns.
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
