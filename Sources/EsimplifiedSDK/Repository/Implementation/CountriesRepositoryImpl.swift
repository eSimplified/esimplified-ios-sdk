//
//  CountriesRepositoryImpl.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/06/04.
//

import Foundation

final class CountriesRepositoryImpl: CountriesRepositoryType {

    private let client: HTTPClient
    private let cache: SdkCache

    init(client: HTTPClient, cache: SdkCache) {
        self.client = client
        self.cache = cache
    }

    func fetchAllCountriesResult(forceRefresh: Bool = false, cacheTTL: TimeInterval = 86400) async -> RepositoryResult<[Country]> {
        let cacheKey = "countries_all"
        if !forceRefresh, let cached: [Country] = await cache.get(cacheKey) {
            return RepositoryResult(value: cached)
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
            return RepositoryResult(value: countries)
        } catch {
            let failure = error as? SdkError ?? .unknown(error)
            let expired: [Country] = await cache.getExpired(cacheKey) ?? []
            return RepositoryResult(value: expired, isStale: !expired.isEmpty, failure: failure)
        }
    }

    /// Preserved signature. One code path with the `Result` variant above.
    func fetchAllCountries(forceRefresh: Bool = false, cacheTTL: TimeInterval = 86400) async -> [Country] {
        await fetchAllCountriesResult(forceRefresh: forceRefresh, cacheTTL: cacheTTL).value
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

    func invalidateCache() async {
        await cache.removeWithPrefix("countries_")
    }
}
