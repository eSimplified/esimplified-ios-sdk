//
//  EsimsRepositoryType.swift
//  EsimplifiedSDK
//

import Foundation

public protocol EsimsRepositoryType {
    func fetchEsims(archivedEsims: Bool) async throws -> [Esim]
    func fetchEsimDetails(iccid: String) async throws -> Esim
    func updateEsimName(customName: String, iccid: String) async throws -> UpdateEsimResponse
    func updateEsimAutoTopUpStatus(status: Bool, iccid: String) async throws -> UpdateEsimResponse
    func updateEsimArchivedStatus(status: Bool, iccid: String) async throws -> UpdateEsimResponse
}
