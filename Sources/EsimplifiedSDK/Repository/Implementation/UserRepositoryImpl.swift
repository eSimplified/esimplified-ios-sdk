//
//  UserRepositoryImpl.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/06/04.
//

import Foundation

final class UserRepositoryImpl: UserRepositoryType {

    private let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }

    func updateProfile(_ request: UpdateCustomerRequest) async throws -> UpdateCustomerResponse {
        try await client.fetch(
            endpoint: .updateCustomer,
            method: .PATCH,
            body: request
        )
    }

    func updatePreferences(_ request: UpdateCustomerPreferencesRequest) async throws -> User {
        try await client.fetch(
            endpoint: .customerPreferences,
            method: .PATCH,
            body: request
        )
    }

    func fetchUserLocation() async throws -> UserLocationResponse {
        try await client.fetch(
            endpoint: .userLocation,
            method: .GET,
            requiresAuth: false
        )
    }
}
