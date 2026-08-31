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

    /// Cache-first read that also reports why a refresh failed. See `RepositoryResult`.
    func fetchAllCountriesResult(forceRefresh: Bool, cacheTTL: TimeInterval) async -> RepositoryResult<[Country]>

}

public extension CountriesRepositoryType {
    func fetchAllCountries(forceRefresh: Bool = false) async -> [Country] {
        await fetchAllCountries(forceRefresh: forceRefresh, cacheTTL: 86400)
    }
}

// MARK: - Result Defaults

/// Defaults so existing conformers — the app's mock and its inline test stubs — keep compiling
/// without change. A conformer that does not override these simply never reports a failure,
/// which is the correct answer for a stub. Only the real implementation overrides them.
public extension CountriesRepositoryType {

    func fetchAllCountriesResult(forceRefresh: Bool, cacheTTL: TimeInterval) async -> RepositoryResult<[Country]> {
        RepositoryResult(value: await fetchAllCountries(forceRefresh: forceRefresh, cacheTTL: cacheTTL))
    }

    func fetchAllCountriesResult(forceRefresh: Bool = false) async -> RepositoryResult<[Country]> {
        await fetchAllCountriesResult(forceRefresh: forceRefresh, cacheTTL: 86400)
    }
}
