//
//  PackagesRepositoryType.swift
//  EsimplifiedSDK
//

import Foundation

public protocol PackagesRepositoryType {
    func fetchPackagesForCountry(countryCode: String?, countryNameSlug: String, forceRefresh: Bool) async throws -> PackageResponse
    func fetchPackagesForTopUpEsim(iccid: String, forceRefresh: Bool) async throws -> [Package]
    func fetchCheckStockForPackage(packageTypeId: Int, forceRefresh: Bool) async throws -> CheckStockResponse
}

public extension PackagesRepositoryType {
    func fetchPackagesForCountry(countryCode: String?, countryNameSlug: String) async throws -> PackageResponse {
        try await fetchPackagesForCountry(countryCode: countryCode, countryNameSlug: countryNameSlug, forceRefresh: false)
    }
    func fetchPackagesForTopUpEsim(iccid: String) async throws -> [Package] {
        try await fetchPackagesForTopUpEsim(iccid: iccid, forceRefresh: false)
    }
    func fetchCheckStockForPackage(packageTypeId: Int) async throws -> CheckStockResponse {
        try await fetchCheckStockForPackage(packageTypeId: packageTypeId, forceRefresh: false)
    }
}
