//
//  OfflineErrorMappingTests.swift
//  EsimplifiedSDK
//
//  A request that never leaves the device must surface as `SdkError.noInternetConnection`,
//  not as `.unknown`. The app decides between the offline sheet and the error sheet from
//  this distinction alone.
//

import Testing
import Foundation
@testable import EsimplifiedSDK

extension NetworkSuite {

    private func offlineTestConfig() -> SdkConfig {
        SdkConfig(
            environment: .staging,
            clientName: "acme",
            clientId: "the-client",
            clientSecret: "the-secret",
            awsWafToken: "",
            customHeadersProvider: nil
        )
    }

    private struct AnyPayload: Decodable {
        let count: Int
    }

    private func fetchFailing(with code: URLError.Code) async -> Error? {
        MockURLProtocol.reset()
        MockURLProtocol.handler = { _ in throw URLError(code) }

        let client = HTTPClient(
            config: offlineTestConfig(),
            sessionProvider: RecordingSessionProvider(),
            session: MockSession.make()
        )

        do {
            _ = try await client.fetch(
                endpoint: .countries,
                method: .GET,
                parameters: nil,
                body: nil,
                id: nil,
                requiresAuth: false
            ) as AnyPayload
            return nil
        } catch {
            return error
        }
    }

    // MARK: Offline Codes Map To noInternetConnection

    @Test(
        "A URLError meaning no connection surfaces as SdkError.noInternetConnection",
        arguments: [
            URLError.Code.notConnectedToInternet,
            .networkConnectionLost,
            .dataNotAllowed,
            .internationalRoamingOff
        ]
    )
    func offlineCodesMapToNoInternetConnection(code: URLError.Code) async {
        let error = await fetchFailing(with: code)

        guard case .noInternetConnection = error as? SdkError else {
            Issue.record("Expected .noInternetConnection for \(code), got \(String(describing: error))")
            return
        }
    }

    // MARK: Other Failures Stay Unknown

    @Test("A timeout is not treated as offline")
    func timeoutIsNotOffline() async {
        let error = await fetchFailing(with: .timedOut)

        guard case .unknown = error as? SdkError else {
            Issue.record("Expected .unknown for a timeout, got \(String(describing: error))")
            return
        }
    }

    // MARK: The Real Session Must Fail Fast When Offline

    @Test("The default session does not wait for connectivity")
    func defaultSessionFailsFastWhenOffline() {
        let configuration = HTTPClient.makeDefaultSessionConfiguration()

        #expect(configuration.waitsForConnectivity == false)
    }

    // MARK: SdkError Knows Which Sheet It Is

    @Test("Only noInternetConnection reports isOffline")
    func onlyNoInternetConnectionIsOffline() {
        #expect(SdkError.noInternetConnection.isOffline)
        #expect(!SdkError.serverError("nope").isOffline)
        #expect(!SdkError.networkError(statusCode: 500, message: "nope").isOffline)
        #expect(!SdkError.authenticationRequired.isOffline)
    }
}
