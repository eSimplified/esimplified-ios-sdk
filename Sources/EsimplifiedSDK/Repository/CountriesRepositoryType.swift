//
//  CountriesRepositoryType.swift
//  EsimplifiedSDK
//

import Foundation

public protocol CountriesRepositoryType {
    func fetchAllCountries(forceRefresh: Bool) async -> [Country]
    func searchCountries(searchTerm: String) async -> [Country]
}
