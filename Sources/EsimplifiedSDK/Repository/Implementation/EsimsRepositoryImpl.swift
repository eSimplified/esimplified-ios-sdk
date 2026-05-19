//
//  EsimsRepositoryImpl.swift
//  EsimplifiedSDK
//

import Foundation

final class EsimsRepositoryImpl: EsimsRepositoryType {

    private let client: HTTPClient
    private let cache: SdkCache

    init(client: HTTPClient, cache: SdkCache) {
        self.client = client
        self.cache = cache
    }

    func fetchEsims(archivedEsims: Bool, forceRefresh: Bool = false) async throws -> [Esim] {
        let cacheKey = "esims_\(archivedEsims)"
        if !forceRefresh, let cached: [Esim] = cache.get(cacheKey) {
            return cached
        }
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
        let esims = response.esims
        cache.set(cacheKey, value: esims, ttl: 300)
        return esims
    }

    func fetchEsimDetails(iccid: String, forceRefresh: Bool = false) async throws -> Esim? {
        let cacheKey = "esim_details_\(iccid)"
        if !forceRefresh, let cached: Esim = cache.get(cacheKey) {
            return cached
        }
        let esim: Esim = try await client.fetch(
            endpoint: .esimDetails,
            method: .GET,
            id: iccid
        )
        cache.set(cacheKey, value: esim, ttl: 300)
        return esim
    }

    func updateEsimName(customName: String, iccid: String) async throws -> UpdateEsimResponse {
        cache.remove("esim_details_\(iccid)")
        cache.remove("esims_true")
        cache.remove("esims_false")
        return try await client.fetch(
            endpoint: .updateEsim,
            method: .PUT,
            body: ["esim_name": customName],
            id: iccid
        )
    }

    func updateEsimAutoTopUpStatus(status: Bool, iccid: String) async throws -> UpdateEsimResponse {
        cache.remove("esim_details_\(iccid)")
        cache.remove("esims_true")
        cache.remove("esims_false")
        return try await client.fetch(
            endpoint: .updateEsim,
            method: .PUT,
            body: ["auto_top_up": status],
            id: iccid
        )
    }

    func updateEsimArchivedStatus(status: Bool, iccid: String) async throws -> UpdateEsimResponse {
        cache.remove("esim_details_\(iccid)")
        cache.remove("esims_true")
        cache.remove("esims_false")
        return try await client.fetch(
            endpoint: .updateEsim,
            method: .PUT,
            body: ["archived": status],
            id: iccid
        )
    }
}
