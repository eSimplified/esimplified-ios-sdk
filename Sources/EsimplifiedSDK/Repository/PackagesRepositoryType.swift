//
//  PackagesRepositoryType.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/06/04.
//

import Foundation

public protocol PackagesRepositoryType {
    func fetchPackagesForCountry(countryCode: String?, countryNameSlug: String, forceRefresh: Bool, cacheTTL: TimeInterval) async -> PackageResponse?
    func fetchPackagesForTopUpEsim(iccid: String, forceRefresh: Bool, cacheTTL: TimeInterval) async -> [Package]
    func fetchCheckStockForPackage(packageTypeId: Int, forceRefresh: Bool, cacheTTL: TimeInterval) async -> CheckStockResponse?
    func invalidateCache() async

    /// Cache-first reads that also report why a refresh failed. See `RepositoryResult`.
    func fetchPackagesForCountryResult(countryCode: String?, countryNameSlug: String, forceRefresh: Bool, cacheTTL: TimeInterval) async -> RepositoryResult<PackageResponse?>
    func fetchPackagesForTopUpEsimResult(iccid: String, forceRefresh: Bool, cacheTTL: TimeInterval) async -> RepositoryResult<[Package]>

}

public extension PackagesRepositoryType {
    func fetchPackagesForCountry(countryCode: String?, countryNameSlug: String, forceRefresh: Bool = false) async -> PackageResponse? {
        await fetchPackagesForCountry(countryCode: countryCode, countryNameSlug: countryNameSlug, forceRefresh: forceRefresh, cacheTTL: 3600)
    }
    func fetchPackagesForTopUpEsim(iccid: String, forceRefresh: Bool = false) async -> [Package] {
        await fetchPackagesForTopUpEsim(iccid: iccid, forceRefresh: forceRefresh, cacheTTL: 3600)
    }
    func fetchCheckStockForPackage(packageTypeId: Int, forceRefresh: Bool = false) async -> CheckStockResponse? {
        await fetchCheckStockForPackage(packageTypeId: packageTypeId, forceRefresh: forceRefresh, cacheTTL: 3600)
    }
}

// MARK: - Result Defaults

/// Defaults so existing conformers — the app's mock and its inline test stubs — keep compiling
/// without change. Only the real implementation overrides them.
public extension PackagesRepositoryType {

    func fetchPackagesForCountryResult(countryCode: String?, countryNameSlug: String, forceRefresh: Bool, cacheTTL: TimeInterval) async -> RepositoryResult<PackageResponse?> {
        RepositoryResult(value: await fetchPackagesForCountry(countryCode: countryCode, countryNameSlug: countryNameSlug, forceRefresh: forceRefresh, cacheTTL: cacheTTL))
    }

    func fetchPackagesForCountryResult(countryCode: String?, countryNameSlug: String, forceRefresh: Bool = false) async -> RepositoryResult<PackageResponse?> {
        await fetchPackagesForCountryResult(countryCode: countryCode, countryNameSlug: countryNameSlug, forceRefresh: forceRefresh, cacheTTL: 3600)
    }

    func fetchPackagesForTopUpEsimResult(iccid: String, forceRefresh: Bool, cacheTTL: TimeInterval) async -> RepositoryResult<[Package]> {
        RepositoryResult(value: await fetchPackagesForTopUpEsim(iccid: iccid, forceRefresh: forceRefresh, cacheTTL: cacheTTL))
    }

    func fetchPackagesForTopUpEsimResult(iccid: String, forceRefresh: Bool = false) async -> RepositoryResult<[Package]> {
        await fetchPackagesForTopUpEsimResult(iccid: iccid, forceRefresh: forceRefresh, cacheTTL: 3600)
    }
}
