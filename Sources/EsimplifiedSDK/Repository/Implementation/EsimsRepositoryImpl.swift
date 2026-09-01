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

    func fetchEsimsResult(
        archivedEsims: Bool,
        showLegacy: Bool = true,
        isPrimary: Bool? = nil,
        forceRefresh: Bool = false,
        cacheTTL: TimeInterval = 86400
    ) async -> RepositoryResult<[Esim]> {
        // 🔴 The cache key carries every parameter that changes WHICH eSIMs come back. Sharing one
        // key would let a universal-only or primary-only response satisfy a later request for the
        // full list, silently hiding eSIMs the customer owns.
        let cacheKey = "esims_\(archivedEsims)_legacy\(showLegacy)_primary\(isPrimary.map(String.init) ?? "any")"
        if !forceRefresh, let cached: [Esim] = await cache.get(cacheKey) {
            return RepositoryResult(value: cached)
        }
        var parameters = [
            "show_package_details": "true",
            "show_balance_remaining": "true",
            "show_esim_details": "true",
            "order_by": "-assigned_date",
            "show_archived_esims": archivedEsims ? "true" : "false"
        ]
        // Service change 2026-09-01: this endpoint returns UNIVERSAL eSIMs only; `show_legacy=true`
        // is required to get everything. Sent EXPLICITLY either way rather than omitted when false,
        // so the request always states its intent — and so it matches the URLs the owner verified:
        //   ?show_legacy=false&is_primary=true  → the home widget's primary eSIM
        //   (no params / show_legacy=false)     → universal only, for My plans and the device picker
        parameters["show_legacy"] = showLegacy ? "true" : "false"

        // Returns exactly one eSIM. The whole list is what makes this endpoint slow — 13s on a
        // large account, measured on device 2026-09-01 — so a caller that only needs the current
        // device should ask for only the current device.
        if let isPrimary {
            parameters["is_primary"] = isPrimary ? "true" : "false"
        }
        do {
            let response: EsimsResponse = try await client.fetch(
                endpoint: .esims,
                method: .GET,
                parameters: parameters
            )
            let esims = response.esims
            await cache.set(cacheKey, value: esims, ttl: cacheTTL)
            return RepositoryResult(value: esims)
        } catch {
            let failure = error as? SdkError ?? .unknown(error)
            let expired: [Esim] = await cache.getExpired(cacheKey) ?? []
            return RepositoryResult(value: expired, isStale: !expired.isEmpty, failure: failure)
        }
    }

    /// Preserved signature. One code path with the `Result` variant above.
    func fetchEsims(
        archivedEsims: Bool,
        showLegacy: Bool = true,
        isPrimary: Bool? = nil,
        forceRefresh: Bool = false,
        cacheTTL: TimeInterval = 86400
    ) async -> [Esim] {
        await fetchEsimsResult(
            archivedEsims: archivedEsims,
            showLegacy: showLegacy,
            isPrimary: isPrimary,
            forceRefresh: forceRefresh,
            cacheTTL: cacheTTL
        ).value
    }

    func fetchEsimDetailsResult(iccid: String, forceRefresh: Bool = false, cacheTTL: TimeInterval = 300) async -> RepositoryResult<Esim?> {
        let cacheKey = "esim_details_\(iccid)"
        if !forceRefresh, let cached: Esim = await cache.get(cacheKey) {
            return RepositoryResult(value: cached)
        }
        do {
            let esim: Esim = try await client.fetch(
                endpoint: .esimDetails,
                method: .GET,
                id: iccid
            )
            await cache.set(cacheKey, value: esim, ttl: cacheTTL)
            return RepositoryResult(value: esim)
        } catch {
            let failure = error as? SdkError ?? .unknown(error)
            let expired: Esim? = await cache.getExpired(cacheKey)
            return RepositoryResult(value: expired, isStale: expired != nil, failure: failure)
        }
    }

    /// Preserved signature. One code path with the `Result` variant above.
    func fetchEsimDetails(iccid: String, forceRefresh: Bool = false, cacheTTL: TimeInterval = 300) async -> Esim? {
        await fetchEsimDetailsResult(iccid: iccid, forceRefresh: forceRefresh, cacheTTL: cacheTTL).value
    }

    func updateEsimNameOrThrow(customName: String, iccid: String) async throws {
        await invalidateEsimCaches(iccid: iccid)
        let response: UpdateEsimResponse = try await client.fetch(
            endpoint: .updateEsim,
            method: .PUT,
            body: ["esim_name": customName],
            id: iccid
        )
        // A 2xx with an unexpected message is a real failure, and a distinct one from a dead
        // request — the Bool signature collapsed both into `false`.
        guard response.message == Self.updateSucceededMessage else {
            throw SdkError.serverError(response.message ?? "The update did not succeed")
        }
    }

    /// Preserved signature. One code path with the throwing variant above.
    func updateEsimName(customName: String, iccid: String) async -> Bool {
        do {
            try await updateEsimNameOrThrow(customName: customName, iccid: iccid)
            return true
        } catch {
            return false
        }
    }

    func updateEsimAutoTopUpStatusOrThrow(status: Bool, iccid: String) async throws {
        await invalidateEsimCaches(iccid: iccid)
        let response: UpdateEsimResponse = try await client.fetch(
            endpoint: .updateEsim,
            method: .PUT,
            body: ["auto_top_up": status],
            id: iccid
        )
        // A 2xx with an unexpected message is a real failure, and a distinct one from a dead
        // request — the Bool signature collapsed both into `false`.
        guard response.message == Self.updateSucceededMessage else {
            throw SdkError.serverError(response.message ?? "The update did not succeed")
        }
    }

    /// Preserved signature. One code path with the throwing variant above.
    func updateEsimAutoTopUpStatus(status: Bool, iccid: String) async -> Bool {
        do {
            try await updateEsimAutoTopUpStatusOrThrow(status: status, iccid: iccid)
            return true
        } catch {
            return false
        }
    }

    func updateEsimArchivedStatusOrThrow(status: Bool, iccid: String) async throws {
        await invalidateEsimCaches(iccid: iccid)
        let response: UpdateEsimResponse = try await client.fetch(
            endpoint: .updateEsim,
            method: .PUT,
            body: ["archived": status],
            id: iccid
        )
        // A 2xx with an unexpected message is a real failure, and a distinct one from a dead
        // request — the Bool signature collapsed both into `false`.
        guard response.message == Self.updateSucceededMessage else {
            throw SdkError.serverError(response.message ?? "The update did not succeed")
        }
    }

    /// Preserved signature. One code path with the throwing variant above.
    func updateEsimArchivedStatus(status: Bool, iccid: String) async -> Bool {
        do {
            try await updateEsimArchivedStatusOrThrow(status: status, iccid: iccid)
            return true
        } catch {
            return false
        }
    }

    func updateEsimPrimaryStatusOrThrow(status: Bool, iccid: String) async throws {
        await invalidateEsimCaches(iccid: iccid)
        let response: UpdateEsimResponse = try await client.fetch(
            endpoint: .updateEsim,
            method: .PUT,
            body: ["is_primary": status],
            id: iccid
        )
        // A 2xx with an unexpected message is a real failure, and a distinct one from a dead
        // request — the Bool signature collapsed both into `false`.
        guard response.message == Self.updateSucceededMessage else {
            throw SdkError.serverError(response.message ?? "The update did not succeed")
        }
    }

    /// Preserved signature. One code path with the throwing variant above.
    func updateEsimPrimaryStatus(status: Bool, iccid: String) async -> Bool {
        do {
            try await updateEsimPrimaryStatusOrThrow(status: status, iccid: iccid)
            return true
        } catch {
            return false
        }
    }

    private static let updateSucceededMessage = "eSIM updated successfully"

    private func invalidateEsimCaches(iccid: String) async {
        await cache.remove("esim_details_\(iccid)")
        await cache.remove("esims_true")
        await cache.remove("esims_false")
    }

    func invalidateCache() async {
        await cache.removeWithPrefix("esims_")
        await cache.removeWithPrefix("esim_details_")
    }
}
