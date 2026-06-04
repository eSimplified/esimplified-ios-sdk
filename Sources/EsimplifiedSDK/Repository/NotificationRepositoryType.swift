//
//  NotificationRepositoryType.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/06/04.
//

import Foundation

public protocol NotificationRepositoryType {
    func fetchNotificationSettings() async -> [NotificationSettings]
    func updateNotificationSettings(settings: [NotificationSettings]) async throws
}
