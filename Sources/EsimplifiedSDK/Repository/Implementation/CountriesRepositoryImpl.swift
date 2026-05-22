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

    func fetchAllCountries(forceRefresh: Bool = false, cacheTTL: TimeInterval = 86400) async -> [Country] {
        let cacheKey = "countries_all"
        if !forceRefresh, let cached: [Country] = await cache.get(cacheKey) {
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
            await cache.set(cacheKey, value: countries, ttl: cacheTTL)
            return countries
        } catch {
            return await cache.getExpired(cacheKey) ?? []
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
