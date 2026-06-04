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
}

public extension CountriesRepositoryType {
    func fetchAllCountries(forceRefresh: Bool = false) async -> [Country] {
        await fetchAllCountries(forceRefresh: forceRefresh, cacheTTL: 86400)
    }
}
