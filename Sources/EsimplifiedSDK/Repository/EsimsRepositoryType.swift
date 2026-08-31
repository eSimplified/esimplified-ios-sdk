//
//  EsimsRepositoryType.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/06/04.
//

import Foundation

public protocol EsimsRepositoryType {
    func fetchEsims(archivedEsims: Bool, forceRefresh: Bool, cacheTTL: TimeInterval) async -> [Esim]
    func fetchEsimDetails(iccid: String, forceRefresh: Bool, cacheTTL: TimeInterval) async -> Esim?
    func updateEsimName(customName: String, iccid: String) async -> Bool
    func updateEsimAutoTopUpStatus(status: Bool, iccid: String) async -> Bool
    func updateEsimArchivedStatus(status: Bool, iccid: String) async -> Bool
    /// Marks this eSIM as the account's current device. Exactly one eSIM is primary at a time —
    /// the service moves the flag off whichever held it.
    func updateEsimPrimaryStatus(status: Bool, iccid: String) async -> Bool
    func invalidateCache() async

    /// Cache-first read that also reports why a refresh failed. See `RepositoryResult`.
    func fetchEsimsResult(archivedEsims: Bool, forceRefresh: Bool, cacheTTL: TimeInterval) async -> RepositoryResult<[Esim]>
    func fetchEsimDetailsResult(iccid: String, forceRefresh: Bool, cacheTTL: TimeInterval) async -> RepositoryResult<Esim?>
    /// Throwing mutations. The `Bool` variants cannot distinguish a dead request from a server
    /// that answered with an unexpected message, so nothing downstream can show a real error.
    func updateEsimNameOrThrow(customName: String, iccid: String) async throws
    func updateEsimAutoTopUpStatusOrThrow(status: Bool, iccid: String) async throws
    func updateEsimArchivedStatusOrThrow(status: Bool, iccid: String) async throws
    func updateEsimPrimaryStatusOrThrow(status: Bool, iccid: String) async throws

}

public extension EsimsRepositoryType {
    func fetchEsims(archivedEsims: Bool, forceRefresh: Bool = false) async -> [Esim] {
        await fetchEsims(archivedEsims: archivedEsims, forceRefresh: forceRefresh, cacheTTL: 86400)
    }
    func fetchEsimDetails(iccid: String, forceRefresh: Bool = false) async -> Esim? {
        await fetchEsimDetails(iccid: iccid, forceRefresh: forceRefresh, cacheTTL: 300)
    }
}

// MARK: - Result And Throwing Defaults

/// Defaults so existing conformers — the app's mock and its inline test stubs — keep compiling
/// without change. Only the real implementation overrides them.
public extension EsimsRepositoryType {

    func fetchEsimsResult(archivedEsims: Bool, forceRefresh: Bool, cacheTTL: TimeInterval) async -> RepositoryResult<[Esim]> {
        RepositoryResult(value: await fetchEsims(archivedEsims: archivedEsims, forceRefresh: forceRefresh, cacheTTL: cacheTTL))
    }

    func fetchEsimsResult(archivedEsims: Bool, forceRefresh: Bool = false) async -> RepositoryResult<[Esim]> {
        await fetchEsimsResult(archivedEsims: archivedEsims, forceRefresh: forceRefresh, cacheTTL: 86400)
    }

    func fetchEsimDetailsResult(iccid: String, forceRefresh: Bool, cacheTTL: TimeInterval) async -> RepositoryResult<Esim?> {
        RepositoryResult(value: await fetchEsimDetails(iccid: iccid, forceRefresh: forceRefresh, cacheTTL: cacheTTL))
    }

    func fetchEsimDetailsResult(iccid: String, forceRefresh: Bool = false) async -> RepositoryResult<Esim?> {
        await fetchEsimDetailsResult(iccid: iccid, forceRefresh: forceRefresh, cacheTTL: 300)
    }

    func updateEsimNameOrThrow(customName: String, iccid: String) async throws {
        guard await updateEsimName(customName: customName, iccid: iccid) else {
            throw SdkError.serverError("The update did not succeed")
        }
    }

    func updateEsimAutoTopUpStatusOrThrow(status: Bool, iccid: String) async throws {
        guard await updateEsimAutoTopUpStatus(status: status, iccid: iccid) else {
            throw SdkError.serverError("The update did not succeed")
        }
    }

    func updateEsimArchivedStatusOrThrow(status: Bool, iccid: String) async throws {
        guard await updateEsimArchivedStatus(status: status, iccid: iccid) else {
            throw SdkError.serverError("The update did not succeed")
        }
    }

    func updateEsimPrimaryStatusOrThrow(status: Bool, iccid: String) async throws {
        guard await updateEsimPrimaryStatus(status: status, iccid: iccid) else {
            throw SdkError.serverError("The update did not succeed")
        }
    }
}
