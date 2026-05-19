//
//  PackagesRepositoryType.swift
//  EsimplifiedSDK
//

import Foundation

public protocol PackagesRepositoryType {
    func fetchPackagesForCountry(countryCode: String?, countryNameSlug: String, forceRefresh: Bool) async -> PackageResponse?
    func fetchPackagesForTopUpEsim(iccid: String, forceRefresh: Bool) async -> [Package]
    func fetchCheckStockForPackage(packageTypeId: Int, forceRefresh: Bool) async -> CheckStockResponse?
}
