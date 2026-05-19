//
//  EsimsRepositoryType.swift
//  EsimplifiedSDK
//

import Foundation

public protocol EsimsRepositoryType {
    func fetchEsims(archivedEsims: Bool, forceRefresh: Bool) async throws -> [Esim]
    func fetchEsimDetails(iccid: String, forceRefresh: Bool) async throws -> Esim?
    func updateEsimName(customName: String, iccid: String) async throws -> UpdateEsimResponse
    func updateEsimAutoTopUpStatus(status: Bool, iccid: String) async throws -> UpdateEsimResponse
    func updateEsimArchivedStatus(status: Bool, iccid: String) async throws -> UpdateEsimResponse
}

public extension EsimsRepositoryType {
    func fetchEsims(archivedEsims: Bool) async throws -> [Esim] {
        try await fetchEsims(archivedEsims: archivedEsims, forceRefresh: false)
    }
    func fetchEsimDetails(iccid: String) async throws -> Esim? {
        try await fetchEsimDetails(iccid: iccid, forceRefresh: false)
    }
}
