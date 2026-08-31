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

    func fetchPackagesForCountryResult(countryCode: String?, countryNameSlug: String, forceRefresh: Bool = false, cacheTTL: TimeInterval = 3600) async -> RepositoryResult<PackageResponse?> {
        let cacheKey = "packages_\(countryCode ?? "")_\(countryNameSlug)"
        if !forceRefresh, let cached: PackageResponse = await cache.get(cacheKey) {
            return RepositoryResult(value: cached)
        }
        let parameters = [
            "country_code": countryCode ?? "",
            "country_name_slug": countryNameSlug,
            "reverse_order": "true"
        ]
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
    func fetchPackagesForCountry(countryCode: String?, countryNameSlug: String, forceRefresh: Bool = false, cacheTTL: TimeInterval = 3600) async -> PackageResponse? {
        await fetchPackagesForCountryResult(countryCode: countryCode, countryNameSlug: countryNameSlug, forceRefresh: forceRefresh, cacheTTL: cacheTTL).value
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
