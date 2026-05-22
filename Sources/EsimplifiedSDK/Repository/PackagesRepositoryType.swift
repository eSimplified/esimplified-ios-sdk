//
//  PackagesRepositoryType.swift
//  EsimplifiedSDK
//

import Foundation

public protocol PackagesRepositoryType {
    func fetchPackagesForCountry(countryCode: String?, countryNameSlug: String, forceRefresh: Bool, cacheTTL: TimeInterval) async -> PackageResponse?
    func fetchPackagesForTopUpEsim(iccid: String, forceRefresh: Bool, cacheTTL: TimeInterval) async -> [Package]
    func fetchCheckStockForPackage(packageTypeId: Int, forceRefresh: Bool, cacheTTL: TimeInterval) async -> CheckStockResponse?
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
