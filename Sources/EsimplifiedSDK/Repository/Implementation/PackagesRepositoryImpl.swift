//
//  PackagesRepositoryImpl.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/06/04.
//

import Foundation

final class PackagesRepositoryImpl: PackagesRepositoryType {

    private let client: HTTPClient
    private let cache: SdkCache

    init(client: HTTPClient, cache: SdkCache) {
        self.client = client
        self.cache = cache
    }

    func fetchPackagesForCountryResult(
        countryCode: String?,
        countryNameSlug: String,
        countryName: String? = nil,
        forceRefresh: Bool = false,
        cacheTTL: TimeInterval = 3600
    ) async -> RepositoryResult<PackageResponse?> {
        let cacheKey = "packages_\(countryCode ?? "")_\(countryNameSlug)_\(countryName ?? "")"
        if !forceRefresh, let cached: PackageResponse = await cache.get(cacheKey) {
            return RepositoryResult(value: cached)
        }
        // `country_name` lets a caller that only has the DISPLAY name — an eSIM's
        // `package_country_name`, say — fetch without first resolving a slug. Home's top-up used to
        // download the entire country catalogue purely to translate "Andorra" into "andorra", which
        // is what made the button feel dead (owner-verified 2026-09-01).
        //
        // Sent only when supplied: the service treats an empty value as a filter that matches
        // nothing, so an unconditional key would break every existing slug-based call.
        var parameters = [
            "country_code": countryCode ?? "",
            "country_name_slug": countryNameSlug,
            "reverse_order": "true"
        ]
        if let countryName, !countryName.isEmpty {
            parameters["country_name"] = countryName
        }
        do {
            let response: PackageResponse = try await client.fetch(
                endpoint: .packages,
                method: .GET,
                parameters: parameters,
                requiresAuth: false
            )
            await cache.set(cacheKey, value: response, ttl: cacheTTL)
            return RepositoryResult(value: response)
        } catch {
            let failure = error as? SdkError ?? .unknown(error)
            let expired: PackageResponse? = await cache.getExpired(cacheKey)
            return RepositoryResult(value: expired, isStale: expired != nil, failure: failure)
        }
    }

    /// Preserved signature. One code path with the `Result` variant above.
    func fetchPackagesForCountry(
        countryCode: String?,
        countryNameSlug: String,
        countryName: String? = nil,
        forceRefresh: Bool = false,
        cacheTTL: TimeInterval = 3600
    ) async -> PackageResponse? {
        await fetchPackagesForCountryResult(
            countryCode: countryCode,
            countryNameSlug: countryNameSlug,
            countryName: countryName,
            forceRefresh: forceRefresh,
            cacheTTL: cacheTTL
        ).value
    }

    func fetchPackagesForTopUpEsimResult(iccid: String, forceRefresh: Bool = false, cacheTTL: TimeInterval = 3600) async -> RepositoryResult<[Package]> {
        let cacheKey = "packages_topup_\(iccid)"
        if !forceRefresh, let cached: [Package] = await cache.get(cacheKey) {
            return RepositoryResult(value: cached)
        }
        let parameters = ["reverse_order": "true"]
        do {
            let response: PackageResponse = try await client.fetch(
                endpoint: .topUpEsim,
                method: .GET,
                parameters: parameters,
                id: iccid
            )
            let packages = response.packages
            await cache.set(cacheKey, value: packages, ttl: cacheTTL)
            return RepositoryResult(value: packages)
        } catch {
            let failure = error as? SdkError ?? .unknown(error)
            let expired: [Package] = await cache.getExpired(cacheKey) ?? []
            return RepositoryResult(value: expired, isStale: !expired.isEmpty, failure: failure)
        }
    }

    /// Preserved signature. One code path with the `Result` variant above.
    func fetchPackagesForTopUpEsim(iccid: String, forceRefresh: Bool = false, cacheTTL: TimeInterval = 3600) async -> [Package] {
        await fetchPackagesForTopUpEsimResult(iccid: iccid, forceRefresh: forceRefresh, cacheTTL: cacheTTL).value
    }

    func fetchCheckStockForPackage(packageTypeId: Int, forceRefresh: Bool = false, cacheTTL: TimeInterval = 3600) async -> CheckStockResponse? {
        let cacheKey = "check_stock_\(packageTypeId)"
        if !forceRefresh, let cached: CheckStockResponse = await cache.get(cacheKey) {
            return cached
        }
        let parameters = ["package_type_id": String(packageTypeId)]
        do {
            let response: CheckStockResponse = try await client.fetch(
                endpoint: .checkStock,
                method: .GET,
                parameters: parameters,
                requiresAuth: false
            )
            await cache.set(cacheKey, value: response, ttl: cacheTTL)
            return response
        } catch {
            return await cache.getExpired(cacheKey)
        }
    }

    func invalidateCache() async {
        await cache.removeWithPrefix("packages_")
        await cache.removeWithPrefix("check_stock_")
    }
}
