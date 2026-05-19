//
//  NotificationSettingsResponse.swift
//  EsimplifiedSDK
//

import Foundation

// MARK: Notification Settings

public struct NotificationSettings: Codable {
    public let type: String
    public let enabled: Bool

    public init(type: String, enabled: Bool) {
        self.type = type
        self.enabled = enabled
    }
}
