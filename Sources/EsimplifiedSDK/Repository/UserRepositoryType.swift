//
//  UserRepositoryType.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/06/04.
//

import Foundation

public protocol UserRepositoryType {
    func updateProfile(_ request: UpdateCustomerRequest) async throws -> UpdateCustomerResponse
    func updatePreferences(_ request: UpdateCustomerPreferencesRequest) async throws -> User
    func fetchUserLocation() async throws -> UserLocationResponse
}
