//
//  NotificationSettingsResponse.swift
//  KnowRoaming
//
//  Created by Kieran on 2025/08/14.
//

import Foundation

// MARK: Notification Settings

public struct NotificationSettings: Codable {
    public let type: String
    public let enabled: Bool
}
