//
//  CountriesRepositoryType.swift
//  EsimplifiedSDK
//

import Foundation

public protocol CountriesRepositoryType {
    func fetchAllCountries(forceRefresh: Bool, cacheTTL: TimeInterval) async -> [Country]
    func searchCountries(searchTerm: String) async -> [Country]
}
