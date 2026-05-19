//
//  PackagesRepositoryImpl.swift
//  EsimplifiedSDK
//

import Foundation

final class PackagesRepositoryImpl: PackagesRepositoryType {

    private let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }

    func fetchPackagesForCountry(countryCode: String?, countryNameSlug: String) async throws -> PackageResponse {
        let parameters = [
            "country_code": countryCode ?? "",
            "country_name_slug": countryNameSlug,
            "reverse_order": "true"
        ]
        return try await client.fetch(
            endpoint: .packages,
            method: .GET,
            parameters: parameters,
            requiresAuth: false
        )
    }

    func fetchPackagesForTopUpEsim(iccid: String) async throws -> [Package] {
        let parameters = ["reverse_order": "true"]
        let response: PackageResponse = try await client.fetch(
            endpoint: .topUpEsim,
            method: .GET,
            parameters: parameters,
            id: iccid
        )
        return response.packages
    }

    func fetchCheckStockForPackage(packageTypeId: Int) async throws -> CheckStockResponse {
        let parameters = ["package_type_id": String(packageTypeId)]
        return try await client.fetch(
            endpoint: .checkStock,
            method: .GET,
            parameters: parameters,
            requiresAuth: false
        )
    }
}
