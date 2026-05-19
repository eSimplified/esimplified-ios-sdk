//
//  UserRepositoryType.swift
//  EsimplifiedSDK
//

import Foundation

public protocol UserRepositoryType {
    func updateProfile(_ request: UpdateCustomerRequest) async throws -> UpdateCustomerResponse
    func updatePreferences(_ request: UpdateCustomerPreferencesRequest) async throws -> User
    func fetchUserLocation() async throws -> UserLocationResponse
}
