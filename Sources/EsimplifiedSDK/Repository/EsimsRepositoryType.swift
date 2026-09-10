//
//  EsimsRepositoryType.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/06/04.
//

import Foundation

public protocol EsimsRepositoryType {
    func fetchEsims(archivedEsims: Bool, showLegacy: Bool, isPrimary: Bool?, forceRefresh: Bool, cacheTTL: TimeInterval) async -> [Esim]
    func fetchEsimDetails(iccid: String, forceRefresh: Bool, cacheTTL: TimeInterval) async -> Esim?
    func updateEsimName(customName: String, iccid: String) async -> Bool
    func updateEsimAutoTopUpStatus(status: Bool, iccid: String) async -> Bool
    func updateEsimArchivedStatus(status: Bool, iccid: String) async -> Bool
    func updateEsimPrimaryStatus(status: Bool, iccid: String) async -> Bool
    func invalidateCache() async

    func fetchEsimsResult(archivedEsims: Bool, showLegacy: Bool, isPrimary: Bool?, forceRefresh: Bool, cacheTTL: TimeInterval) async -> RepositoryResult<[Esim]>
    func fetchEsimDetailsResult(iccid: String, forceRefresh: Bool, cacheTTL: TimeInterval) async -> RepositoryResult<Esim?>

    func fetchEsimsResult(archivedEsims: Bool, showLegacy: Bool, isPrimary: Bool?, includeBase64QrCode: Bool, forceRefresh: Bool, cacheTTL: TimeInterval) async -> RepositoryResult<[Esim]>
    func fetchEsimDetailsResult(iccid: String, includeBase64QrCode: Bool, forceRefresh: Bool, cacheTTL: TimeInterval) async -> RepositoryResult<Esim?>
    func updateEsimNameOrThrow(customName: String, iccid: String) async throws
    func updateEsimAutoTopUpStatusOrThrow(status: Bool, iccid: String) async throws
    func updateEsimArchivedStatusOrThrow(status: Bool, iccid: String) async throws
    func updateEsimPrimaryStatusOrThrow(status: Bool, iccid: String) async throws

}

public extension EsimsRepositoryType {
    func fetchEsims(
        archivedEsims: Bool,
        showLegacy: Bool = true,
        isPrimary: Bool? = nil,
        forceRefresh: Bool = false
    ) async -> [Esim] {
        await fetchEsims(
            archivedEsims: archivedEsims,
            showLegacy: showLegacy,
            isPrimary: isPrimary,
            forceRefresh: forceRefresh,
            cacheTTL: 86400
        )
    }

    func fetchEsimsResult(
        archivedEsims: Bool,
        showLegacy: Bool = true,
        isPrimary: Bool? = nil,
        forceRefresh: Bool = false
    ) async -> RepositoryResult<[Esim]> {
        await fetchEsimsResult(
            archivedEsims: archivedEsims,
            showLegacy: showLegacy,
            isPrimary: isPrimary,
            forceRefresh: forceRefresh,
            cacheTTL: 86400
        )
    }
    func fetchEsimDetails(iccid: String, forceRefresh: Bool = false) async -> Esim? {
        await fetchEsimDetails(iccid: iccid, forceRefresh: forceRefresh, cacheTTL: 300)
    }

    func fetchEsims(
        archivedEsims: Bool,
        showLegacy: Bool = true,
        isPrimary: Bool? = nil,
        includeBase64QrCode: Bool,
        forceRefresh: Bool = false,
        cacheTTL: TimeInterval = 86400
    ) async -> [Esim] {
        await fetchEsimsResult(
            archivedEsims: archivedEsims,
            showLegacy: showLegacy,
            isPrimary: isPrimary,
            includeBase64QrCode: includeBase64QrCode,
            forceRefresh: forceRefresh,
            cacheTTL: cacheTTL
        ).value
    }

    func fetchEsimDetails(
        iccid: String,
        includeBase64QrCode: Bool,
        forceRefresh: Bool = false,
        cacheTTL: TimeInterval = 300
    ) async -> Esim? {
        await fetchEsimDetailsResult(
            iccid: iccid,
            includeBase64QrCode: includeBase64QrCode,
            forceRefresh: forceRefresh,
            cacheTTL: cacheTTL
        ).value
    }

    func fetchEsimsResult(
        archivedEsims: Bool,
        showLegacy: Bool = true,
        isPrimary: Bool? = nil,
        includeBase64QrCode: Bool,
        forceRefresh: Bool = false
    ) async -> RepositoryResult<[Esim]> {
        await fetchEsimsResult(
            archivedEsims: archivedEsims,
            showLegacy: showLegacy,
            isPrimary: isPrimary,
            includeBase64QrCode: includeBase64QrCode,
            forceRefresh: forceRefresh,
            cacheTTL: 86400
        )
    }

    func fetchEsimsResult(
        archivedEsims: Bool,
        showLegacy: Bool,
        isPrimary: Bool?,
        includeBase64QrCode: Bool,
        forceRefresh: Bool,
        cacheTTL: TimeInterval
    ) async -> RepositoryResult<[Esim]> {
        await fetchEsimsResult(
            archivedEsims: archivedEsims,
            showLegacy: showLegacy,
            isPrimary: isPrimary,
            forceRefresh: forceRefresh,
            cacheTTL: cacheTTL
        )
    }

    func fetchEsimDetailsResult(
        iccid: String,
        includeBase64QrCode: Bool,
        forceRefresh: Bool,
        cacheTTL: TimeInterval
    ) async -> RepositoryResult<Esim?> {
        await fetchEsimDetailsResult(iccid: iccid, forceRefresh: forceRefresh, cacheTTL: cacheTTL)
    }
}

// MARK: - Result And Throwing Defaults

public extension EsimsRepositoryType {

    func fetchEsimsResult(archivedEsims: Bool, showLegacy: Bool, isPrimary: Bool?, forceRefresh: Bool, cacheTTL: TimeInterval) async -> RepositoryResult<[Esim]> {
        RepositoryResult(value: await fetchEsims(
            archivedEsims: archivedEsims,
            showLegacy: showLegacy,
            isPrimary: isPrimary,
            forceRefresh: forceRefresh,
            cacheTTL: cacheTTL
        ))
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
