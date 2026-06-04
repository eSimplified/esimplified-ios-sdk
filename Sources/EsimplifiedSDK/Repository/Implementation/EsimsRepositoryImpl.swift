//
//  EsimsRepositoryImpl.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/06/04.
//

import Foundation

final class EsimsRepositoryImpl: EsimsRepositoryType {

    private let client: HTTPClient
    private let cache: SdkCache

    init(client: HTTPClient, cache: SdkCache) {
        self.client = client
        self.cache = cache
    }

    func fetchEsims(archivedEsims: Bool, forceRefresh: Bool = false, cacheTTL: TimeInterval = 86400) async -> [Esim] {
        let cacheKey = "esims_\(archivedEsims)"
        if !forceRefresh, let cached: [Esim] = await cache.get(cacheKey) {
            return cached
        }
        let parameters = [
            "show_package_details": "true",
            "show_balance_remaining": "true",
            "show_esim_details": "true",
            "order_by": "-assigned_date",
            "show_archived_esims": archivedEsims ? "true" : "false"
        ]
        do {
            let response: EsimsResponse = try await client.fetch(
                endpoint: .esims,
                method: .GET,
                parameters: parameters
            )
            let esims = response.esims
            await cache.set(cacheKey, value: esims, ttl: cacheTTL)
            return esims
        } catch {
            return await cache.getExpired(cacheKey) ?? []
        }
    }

    func fetchEsimDetails(iccid: String, forceRefresh: Bool = false, cacheTTL: TimeInterval = 300) async -> Esim? {
        let cacheKey = "esim_details_\(iccid)"
        if !forceRefresh, let cached: Esim = await cache.get(cacheKey) {
            return cached
        }
        do {
            let esim: Esim = try await client.fetch(
                endpoint: .esimDetails,
                method: .GET,
                id: iccid
            )
            await cache.set(cacheKey, value: esim, ttl: cacheTTL)
            return esim
        } catch {
            return await cache.getExpired(cacheKey)
        }
    }

    func updateEsimName(customName: String, iccid: String) async -> Bool {
        await cache.remove("esim_details_\(iccid)")
        await cache.remove("esims_true")
        await cache.remove("esims_false")
        do {
            let response: UpdateEsimResponse = try await client.fetch(
                endpoint: .updateEsim,
                method: .PUT,
                body: ["esim_name": customName],
                id: iccid
            )
            return response.message == "eSIM updated successfully"
        } catch {
            return false
        }
    }

    func updateEsimAutoTopUpStatus(status: Bool, iccid: String) async -> Bool {
        await cache.remove("esim_details_\(iccid)")
        await cache.remove("esims_true")
        await cache.remove("esims_false")
        do {
            let response: UpdateEsimResponse = try await client.fetch(
                endpoint: .updateEsim,
                method: .PUT,
                body: ["auto_top_up": status],
                id: iccid
            )
            return response.message == "eSIM updated successfully"
        } catch {
            return false
        }
    }

    func updateEsimArchivedStatus(status: Bool, iccid: String) async -> Bool {
        await cache.remove("esim_details_\(iccid)")
        await cache.remove("esims_true")
        await cache.remove("esims_false")
        do {
            let response: UpdateEsimResponse = try await client.fetch(
                endpoint: .updateEsim,
                method: .PUT,
                body: ["archived": status],
                id: iccid
            )
            return response.message == "eSIM updated successfully"
        } catch {
            return false
        }
    }

    func invalidateCache() async {
        await cache.removeWithPrefix("esims_")
        await cache.removeWithPrefix("esim_details_")
    }
}
