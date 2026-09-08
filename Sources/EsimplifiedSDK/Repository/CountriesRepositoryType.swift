//
//  CountriesRepositoryType.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/06/04.
//

import Foundation

public protocol CountriesRepositoryType {
    func fetchAllCountries(forceRefresh: Bool, cacheTTL: TimeInterval) async -> [Country]
    func searchCountries(searchTerm: String) async -> [Country]
    func invalidateCache() async

    func fetchAllCountriesResult(forceRefresh: Bool, cacheTTL: TimeInterval) async -> RepositoryResult<[Country]>

}

public extension CountriesRepositoryType {
    func fetchAllCountries(forceRefresh: Bool = false) async -> [Country] {
        await fetchAllCountries(forceRefresh: forceRefresh, cacheTTL: 86400)
    }
}

// MARK: - Result Defaults

public extension CountriesRepositoryType {

    func fetchAllCountriesResult(forceRefresh: Bool, cacheTTL: TimeInterval) async -> RepositoryResult<[Country]> {
        RepositoryResult(value: await fetchAllCountries(forceRefresh: forceRefresh, cacheTTL: cacheTTL))
    }

    func fetchAllCountriesResult(forceRefresh: Bool = false) async -> RepositoryResult<[Country]> {
        await fetchAllCountriesResult(forceRefresh: forceRefresh, cacheTTL: 86400)
    }
}
