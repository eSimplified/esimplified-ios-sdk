//
//  LocalizationRepositoryType.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/11/18.
//

import Foundation

public protocol LocalizationRepositoryType {

    // MARK: Localization

    func fetchLocalization(include: LocalizationInclude?, forceRefresh: Bool, cacheTTL: TimeInterval) async -> Localization
    func fetchLocalizationResult(include: LocalizationInclude?, forceRefresh: Bool, cacheTTL: TimeInterval) async -> RepositoryResult<Localization>
    func invalidateCache() async
}

public extension LocalizationRepositoryType {

    func fetchLocalization(include: LocalizationInclude? = nil, forceRefresh: Bool = false) async -> Localization {
        await fetchLocalization(include: include, forceRefresh: forceRefresh, cacheTTL: 3600)
    }

    func fetchLocalizationResult(include: LocalizationInclude? = nil, forceRefresh: Bool = false) async -> RepositoryResult<Localization> {
        await fetchLocalizationResult(include: include, forceRefresh: forceRefresh, cacheTTL: 3600)
    }
}
