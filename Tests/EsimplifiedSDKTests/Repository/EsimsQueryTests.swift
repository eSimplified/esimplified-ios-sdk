//
//  EsimsQueryTests.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/09/01.
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

    @Test("eSIMs: changing the default device throws away every cached eSIM list, whatever its filters")
    func primaryChangeInvalidatesEveryListCache() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = { request in
            let url = request.url!
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["Content-Type": "application/json"])!
            let json = request.httpMethod == "PUT" ? #"{"message": "eSIM updated successfully"}"# : #"{"esims": []}"#
            return (response, Data(json.utf8))
        }
        let (client, cache) = makeEsimsEnv()
        let repo = EsimsRepositoryImpl(client: client, cache: cache)

        _ = await repo.fetchEsims(archivedEsims: false, showLegacy: false)
        _ = await repo.fetchEsims(archivedEsims: false, showLegacy: false, isPrimary: true)
        let requestsBeforeUpdate = MockURLProtocol.capturedRequests.count

        let didUpdate = await repo.updateEsimPrimaryStatus(status: true, iccid: "8900")
        _ = await repo.fetchEsims(archivedEsims: false, showLegacy: false)
        _ = await repo.fetchEsims(archivedEsims: false, showLegacy: false, isPrimary: true)

        #expect(didUpdate)
        #expect(requestsBeforeUpdate == 2)
        #expect(MockURLProtocol.capturedRequests.count == 5)
    }
}
