//
//  CountriesRepositoryType.swift
//  EsimplifiedSDK
//

import Foundation

public protocol CountriesRepositoryType {
    func fetchAllCountries() async throws -> [Country]
    func searchCountries(searchTerm: String) async throws -> [Country]
}
