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
