//
//  PromoCodeRepositoryType.swift
//  EsimplifiedSDK
//

import Foundation

public protocol PromoCodeRepositoryType {
    func fetchPromocode() async throws -> PromoCodeResponse
    func applyPromocode(code: String) async throws -> PromoCodeResponse
    func deletePromocode(code: String) async throws -> PromoCodeResponse
}
