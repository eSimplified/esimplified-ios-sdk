//
//  PromoCodeRepositoryType.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/06/04.
//

import Foundation

public protocol PromoCodeRepositoryType {
    func fetchPromocode() async throws -> PromoCodeResponse
    func applyPromocode(code: String) async throws -> PromoCodeResponse
    func deletePromocode(code: String) async throws -> PromoCodeResponse
}
