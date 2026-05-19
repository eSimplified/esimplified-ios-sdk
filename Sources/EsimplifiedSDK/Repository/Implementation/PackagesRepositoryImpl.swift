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

    func fetchPackagesForCountry(countryCode: String?, countryNameSlug: String, forceRefresh: Bool = false) async throws -> PackageResponse {
        let cacheKey = "packages_\(countryCode ?? "")_\(countryNameSlug)"
        if !forceRefresh, let cached: PackageResponse = cache.get(cacheKey) {
            return cached
        }
        let parameters = [
            "country_code": countryCode ?? "",
            "country_name_slug": countryNameSlug,
            "reverse_order": "true"
        ]
        let response: PackageResponse = try await client.fetch(
            endpoint: .packages,
            method: .GET,
            parameters: parameters,
            requiresAuth: false
        )
        cache.set(cacheKey, value: response)
        return response
    }

    func fetchPackagesForTopUpEsim(iccid: String, forceRefresh: Bool = false) async throws -> [Package] {
        let cacheKey = "packages_topup_\(iccid)"
        if !forceRefresh, let cached: [Package] = cache.get(cacheKey) {
            return cached
        }
        let parameters = ["reverse_order": "true"]
        let response: PackageResponse = try await client.fetch(
            endpoint: .topUpEsim,
            method: .GET,
            parameters: parameters,
            id: iccid
        )
        let packages = response.packages
        cache.set(cacheKey, value: packages)
        return packages
    }

    func fetchCheckStockForPackage(packageTypeId: Int, forceRefresh: Bool = false) async throws -> CheckStockResponse {
        let cacheKey = "check_stock_\(packageTypeId)"
        if !forceRefresh, let cached: CheckStockResponse = cache.get(cacheKey) {
            return cached
        }
        let parameters = ["package_type_id": String(packageTypeId)]
        let response: CheckStockResponse = try await client.fetch(
            endpoint: .checkStock,
            method: .GET,
            parameters: parameters,
            requiresAuth: false
        )
        cache.set(cacheKey, value: response, ttl: 300)
        return response
    }
}
