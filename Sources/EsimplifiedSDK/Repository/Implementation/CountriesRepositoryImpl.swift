//
//  CountriesRepositoryImpl.swift
//  EsimplifiedSDK
//

import Foundation

final class CountriesRepositoryImpl: CountriesRepositoryType {

    private let client: HTTPClient
    private let cache: SdkCache

    init(client: HTTPClient, cache: SdkCache) {
        self.client = client
        self.cache = cache
    }

    func fetchAllCountries(forceRefresh: Bool = false) async -> [Country] {
        let cacheKey = "countries_all"
        if !forceRefresh, let cached: [Country] = cache.get(cacheKey) {
            return cached
        }
        let parameters = ["limit": "1000"]
        do {
            let response: CountryResponse = try await client.fetch(
                endpoint: .countries,
                method: .GET,
                parameters: parameters,
                requiresAuth: false
            )
            let countries = response.countries
            cache.set(cacheKey, value: countries, ttl: 86400)
            return countries
        } catch {
            return []
        }
    }

    func searchCountries(searchTerm: String) async -> [Country] {
        let parameters = ["search_term": searchTerm]
        do {
            let response: CountryResponse = try await client.fetch(
                endpoint: .search,
                method: .GET,
                parameters: parameters,
                requiresAuth: false
            )
            return response.countries
        } catch {
            return []
        }
    }
}
