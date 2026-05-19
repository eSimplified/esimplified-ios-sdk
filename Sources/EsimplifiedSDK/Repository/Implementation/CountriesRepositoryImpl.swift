//
//  CountriesRepositoryImpl.swift
//  EsimplifiedSDK
//

import Foundation

final class CountriesRepositoryImpl: CountriesRepositoryType {

    private let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }

    func fetchAllCountries() async throws -> [Country] {
        let parameters = ["limit": "1000"]
        let response: CountryResponse = try await client.fetch(
            endpoint: .countries,
            method: .GET,
            parameters: parameters,
            requiresAuth: false
        )
        return response.countries
    }

    func searchCountries(searchTerm: String) async throws -> [Country] {
        let parameters = ["search_term": searchTerm]
        let response: CountryResponse = try await client.fetch(
            endpoint: .search,
            method: .GET,
            parameters: parameters,
            requiresAuth: false
        )
        return response.countries
    }
}
