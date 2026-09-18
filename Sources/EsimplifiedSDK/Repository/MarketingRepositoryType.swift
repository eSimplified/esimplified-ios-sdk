//
//  MarketingRepositoryType.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/09/18.
//

import Foundation

public protocol MarketingRepositoryType {

    // MARK: Promos

    func fetchPromos(language: String, forceRefresh: Bool, cacheTTL: TimeInterval) async -> [Promo]

    func fetchPromosResult(language: String, forceRefresh: Bool, cacheTTL: TimeInterval) async -> RepositoryResult<[Promo]>

    func invalidateCache() async
}

public extension MarketingRepositoryType {

    func fetchPromos(language: String, forceRefresh: Bool = false) async -> [Promo] {
        await fetchPromos(language: language, forceRefresh: forceRefresh, cacheTTL: 3600)
    }

    func fetchPromosResult(language: String, forceRefresh: Bool = false) async -> RepositoryResult<[Promo]> {
        await fetchPromosResult(language: language, forceRefresh: forceRefresh, cacheTTL: 3600)
    }
}
