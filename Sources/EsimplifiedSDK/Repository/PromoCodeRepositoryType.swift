//
//  PromoCodeRepositoryType.swift
//  EsimplifiedSDK
//

import Foundation

public protocol PromoCodeRepositoryType {
    func fetchPromoCode() async throws -> PromoCodeResponse
    func applyPromoCode(code: String) async throws -> PromoCodeResponse
    func deletePromoCode(code: String) async throws -> PromoCodeResponse
}
