//
//  EsimQrCodeTests.swift
//  EsimplifiedSDK
//

import Testing
import Foundation
@testable import EsimplifiedSDK

extension NetworkSuite {

    private func makeEsimsRepo() -> (EsimsRepositoryImpl, SdkCache) {
        let config = SdkConfig(environment: .staging, clientName: "acme",
                               clientId: "id", clientSecret: "secret")
        let session = RecordingSessionProvider(
            initial: .authenticated(accessToken: "a", refreshToken: "r",
                                    expiresAt: Date().addingTimeInterval(3600))
        )
        let client = HTTPClient(config: config, sessionProvider: session, session: MockSession.make())
        let cache = SdkCache()
        return (EsimsRepositoryImpl(client: client, cache: cache), cache)
    }

    private static let esimWithQr = #"""
    {"count":1,"next":null,"previous":null,"results":[
      {"iccid":"250700000031473","order_uuid":"51cb3890","android_sha":false,"archived":false,
       "order_number":"8011","assigned_date":"2026-08-20T12:44:23.339874Z",
       "data_usage_remaining_bytes":-1,"data_usage_remaining_gigabytes":-1,
       "esim_name":"Kieran's eSIM","auto_top_up":false,"is_universal":true,"is_primary":true,
       "esim_provider":"TEST",
       "sm_dp_address":"test.esim.com","activation_code":"25011473",
       "qr_code_image_base64":"aVZCT1J3MEtHZ28=",
       "profile":{"state":"ERROR","last_operation_date":1788989642,
                  "activation_code":"LPA:1$test.esim.com$TN226021414E0101F",
                  "reuse_remaining_count":3,"reuse_enabled":true,"cc_required":false,
                  "release_date":1703796970,"state_message":"error",
                  "last_operation_date_utc":"2026-09-09T21:34:02Z",
                  "release_date_utc":"2026-09-09T21:34:02Z"}}
    ]}
    """#

    // MARK: The New Fields Decode

    @Test("An eSIM decodes the address, matching ID and QR code the API now returns")
    func esimDecodesInstallFields() async {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: Self.esimWithQr)

        let (repo, _) = makeEsimsRepo()
        let esim = await repo.fetchEsims(archivedEsims: false, includeBase64QrCode: true).first

        #expect(esim?.smDpAddress == "test.esim.com")
        #expect(esim?.activationCode == "25011473")
        #expect(esim?.qrCodeImageBase64 == "aVZCT1J3MEtHZ28=")
        #expect(esim?.esimProvider == "TEST")
    }

    @Test("The eSIM's matching ID is its own, not the LPA string on the profile")
    func theMatchingIdIsNotTheProfilesLpaString() async {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: Self.esimWithQr)

        let (repo, _) = makeEsimsRepo()
        let esim = await repo.fetchEsims(archivedEsims: false, includeBase64QrCode: true).first

        #expect(esim?.profile?.activationCode == "LPA:1$test.esim.com$TN226021414E0101F")
        #expect(esim?.activationCode != esim?.profile?.activationCode)
    }

    @Test("An eSIM carrying both halves reports that it can install on its own")
    func anEsimWithBothHalvesCanInstall() async {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: Self.esimWithQr)

        let (repo, _) = makeEsimsRepo()
        let esim = await repo.fetchEsims(archivedEsims: false, includeBase64QrCode: true).first

        #expect(esim?.canInstallDirectly == true)
    }

    @Test("An eSIM missing either half reports that it cannot")
    func anEsimMissingAHalfCannotInstall() {
        let base = Esim(
            iccid: "1", androidSha: false, archived: false, assignedDate: "",
            dataUsageRemainingBytes: 0, dataUsageRemainingGigabytes: 0, autoTopUp: false
        )
        #expect(base.canInstallDirectly == false)

        let addressOnly = Esim(
            iccid: "1", androidSha: false, archived: false, assignedDate: "",
            dataUsageRemainingBytes: 0, dataUsageRemainingGigabytes: 0, autoTopUp: false,
            smDpAddress: "test.esim.com"
        )
        #expect(addressOnly.canInstallDirectly == false)

        let empty = Esim(
            iccid: "1", androidSha: false, archived: false, assignedDate: "",
            dataUsageRemainingBytes: 0, dataUsageRemainingGigabytes: 0, autoTopUp: false,
            smDpAddress: "", activationCode: ""
        )
        #expect(empty.canInstallDirectly == false)
    }

    // MARK: The Request Asks For It

    @Test("Asking for the QR sends include_base64_qr_code on the list read")
    func listReadSendsTheFlag() async {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: Self.esimWithQr)

        let (repo, _) = makeEsimsRepo()
        _ = await repo.fetchEsims(archivedEsims: false, isPrimary: true, includeBase64QrCode: true)

        let query = MockURLProtocol.capturedRequests.first?.url?.query ?? ""
        #expect(query.contains("include_base64_qr_code=true"))
        #expect(query.contains("is_primary=true"))
    }

    @Test("Not asking for it leaves the parameter off entirely")
    func notAskingOmitsTheFlag() async {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: Self.esimWithQr)

        let (repo, _) = makeEsimsRepo()
        _ = await repo.fetchEsims(archivedEsims: false)

        let query = MockURLProtocol.capturedRequests.first?.url?.query ?? ""
        #expect(!query.contains("include_base64_qr_code"))
    }

    @Test("Asking for the QR sends the flag on the details read too")
    func detailsReadSendsTheFlag() async {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: #"{"iccid":"250700000031473","android_sha":false,"archived":false,"assigned_date":"","data_usage_remaining_bytes":-1,"data_usage_remaining_gigabytes":-1,"auto_top_up":false,"is_primary":true,"sm_dp_address":"test.esim.com","activation_code":"25011473","qr_code_image_base64":"aVZCT1J3MEtHZ28="}"#)

        let (repo, _) = makeEsimsRepo()
        let esim = await repo.fetchEsimDetails(iccid: "250700000031473", includeBase64QrCode: true)

        let query = MockURLProtocol.capturedRequests.first?.url?.query ?? ""
        #expect(query.contains("include_base64_qr_code=true"))
        #expect(esim?.qrCodeImageBase64 == "aVZCT1J3MEtHZ28=")
    }

    // MARK: A QR-Less Response Is Never Served To A QR Request

    @Test("A read without the QR does not satisfy a later read that wants one")
    func aQrLessCacheEntryIsNotReused() async {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: Self.esimWithQr)

        let (repo, _) = makeEsimsRepo()
        _ = await repo.fetchEsims(archivedEsims: false)
        let afterFirst = MockURLProtocol.capturedRequests.count

        _ = await repo.fetchEsims(archivedEsims: false, includeBase64QrCode: true)

        #expect(
            MockURLProtocol.capturedRequests.count == afterFirst + 1,
            "the QR request must go to the network rather than reuse the QR-less entry"
        )
    }
}
