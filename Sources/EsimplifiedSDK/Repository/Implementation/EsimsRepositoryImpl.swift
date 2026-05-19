//
//  EsimsRepositoryImpl.swift
//  EsimplifiedSDK
//

import Foundation

final class EsimsRepositoryImpl: EsimsRepositoryType {

    private let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }

    func fetchEsims(archivedEsims: Bool) async throws -> [Esim] {
        let parameters = [
            "show_package_details": "true",
            "show_balance_remaining": "true",
            "show_esim_details": "true",
            "order_by": "-assigned_date",
            "show_archived_esims": archivedEsims ? "true" : "false"
        ]
        let response: EsimsResponse = try await client.fetch(
            endpoint: .esims,
            method: .GET,
            parameters: parameters
        )
        return response.esims
    }

    func fetchEsimDetails(iccid: String) async throws -> Esim {
        try await client.fetch(
            endpoint: .esimDetails,
            method: .GET,
            id: iccid
        )
    }

    func updateEsimName(customName: String, iccid: String) async throws -> UpdateEsimResponse {
        try await client.fetch(
            endpoint: .updateEsim,
            method: .PUT,
            body: ["esim_name": customName],
            id: iccid
        )
    }

    func updateEsimAutoTopUpStatus(status: Bool, iccid: String) async throws -> UpdateEsimResponse {
        try await client.fetch(
            endpoint: .updateEsim,
            method: .PUT,
            body: ["auto_top_up": status],
            id: iccid
        )
    }

    func updateEsimArchivedStatus(status: Bool, iccid: String) async throws -> UpdateEsimResponse {
        try await client.fetch(
            endpoint: .updateEsim,
            method: .PUT,
            body: ["archived": status],
            id: iccid
        )
    }
}
