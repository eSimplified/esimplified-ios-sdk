//
//  CountriesRepositoryType.swift
//  EsimplifiedSDK
//

import Foundation

public protocol CountriesRepositoryType {
    func fetchAllCountries(forceRefresh: Bool, cacheTTL: TimeInterval) async -> [Country]
    func searchCountries(searchTerm: String) async -> [Country]
}

public extension CountriesRepositoryType {
    func fetchAllCountries(forceRefresh: Bool = false) async -> [Country] {
        await fetchAllCountries(forceRefresh: forceRefresh, cacheTTL: 86400)
    }
}
