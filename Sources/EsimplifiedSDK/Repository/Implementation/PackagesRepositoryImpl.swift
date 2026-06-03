//
//  PackagesRepositoryImpl.swift
//  EsimplifiedSDK
//

import Foundation

final class PackagesRepositoryImpl: PackagesRepositoryType {

    private let client: HTTPClient
    private let cache: SdkCache

    init(client: HTTPClient, cache: SdkCache) {
        self.client = client
        self.cache = cache
    }

    func fetchPackagesForCountry(countryCode: String?, countryNameSlug: String, forceRefresh: Bool = false, cacheTTL: TimeInterval = 3600) async -> PackageResponse? {
        let cacheKey = "packages_\(countryCode ?? "")_\(countryNameSlug)"
        if !forceRefresh, let cached: PackageResponse = await cache.get(cacheKey) {
            return cached
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
            return response
        } catch {
            return await cache.getExpired(cacheKey)
        }
    }

    func fetchPackagesForTopUpEsim(iccid: String, forceRefresh: Bool = false, cacheTTL: TimeInterval = 3600) async -> [Package] {
        let cacheKey = "packages_topup_\(iccid)"
        if !forceRefresh, let cached: [Package] = await cache.get(cacheKey) {
            return cached
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
            return packages
        } catch {
            return await cache.getExpired(cacheKey) ?? []
        }
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
