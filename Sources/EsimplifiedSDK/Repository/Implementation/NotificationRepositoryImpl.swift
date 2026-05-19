//
//  NotificationRepositoryImpl.swift
//  EsimplifiedSDK
//

import Foundation

final class NotificationRepositoryImpl: NotificationRepositoryType {

    private let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }

    func fetchNotificationSettings() async throws -> [NotificationSettings] {
        try await client.fetch(
            endpoint: .notificationSettings,
            method: .GET
        )
    }

    func updateNotificationSettings(settings: [NotificationSettings]) async throws {
        let _: [NotificationSettings] = try await client.fetch(
            endpoint: .notificationSettings,
            method: .PATCH,
            body: settings
        )
    }
}
