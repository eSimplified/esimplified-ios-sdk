//
//  CountriesRepositoryType.swift
//  EsimplifiedSDK
//

import Foundation

public protocol CountriesRepositoryType {
    func fetchAllCountries(forceRefresh: Bool) async throws -> [Country]
    func searchCountries(searchTerm: String) async throws -> [Country]
}

public extension CountriesRepositoryType {
    func fetchAllCountries() async throws -> [Country] {
        try await fetchAllCountries(forceRefresh: false)
    }
}
