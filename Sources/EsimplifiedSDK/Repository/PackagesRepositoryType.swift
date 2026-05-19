//
//  PackagesRepositoryType.swift
//  EsimplifiedSDK
//

import Foundation

public protocol PackagesRepositoryType {
    func fetchPackagesForCountry(countryCode: String?, countryNameSlug: String) async throws -> PackageResponse
    func fetchPackagesForTopUpEsim(iccid: String) async throws -> [Package]
    func fetchCheckStockForPackage(packageTypeId: Int) async throws -> CheckStockResponse
}
