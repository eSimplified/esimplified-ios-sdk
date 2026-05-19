//
//  NotificationRepositoryType.swift
//  EsimplifiedSDK
//

import Foundation

public protocol NotificationRepositoryType {
    func fetchNotificationSettings() async -> [NotificationSettings]
    func updateNotificationSettings(settings: [NotificationSettings]) async throws
}
