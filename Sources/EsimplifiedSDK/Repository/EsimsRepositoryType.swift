//
//  EsimsRepositoryType.swift
//  EsimplifiedSDK
//

import Foundation

public protocol EsimsRepositoryType {
    func fetchEsims(archivedEsims: Bool, forceRefresh: Bool, cacheTTL: TimeInterval) async -> [Esim]
    func fetchEsimDetails(iccid: String, forceRefresh: Bool, cacheTTL: TimeInterval) async -> Esim?
    func updateEsimName(customName: String, iccid: String) async -> Bool
    func updateEsimAutoTopUpStatus(status: Bool, iccid: String) async -> Bool
    func updateEsimArchivedStatus(status: Bool, iccid: String) async -> Bool
    func invalidateCache() async
}

public extension EsimsRepositoryType {
    func fetchEsims(archivedEsims: Bool, forceRefresh: Bool = false) async -> [Esim] {
        await fetchEsims(archivedEsims: archivedEsims, forceRefresh: forceRefresh, cacheTTL: 86400)
    }
    func fetchEsimDetails(iccid: String, forceRefresh: Bool = false) async -> Esim? {
        await fetchEsimDetails(iccid: iccid, forceRefresh: forceRefresh, cacheTTL: 300)
    }
}
