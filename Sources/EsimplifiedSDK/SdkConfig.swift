//
//  SdkConfig.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/06/04.
//

import Foundation

public enum SdkEnvironment: Equatable {
    case staging
    case production
}

public struct SdkConfig {
    public let environment: SdkEnvironment
    public let clientName: String
    public let apiVersion: String
    public let clientId: String
    public let clientSecret: String
    public let awsWafToken: String
    public let enableLogging: Bool
    public let enableCaching: Bool
    public let defaultCacheTTL: TimeInterval
    public let customHeadersProvider: (() async -> [String: String])?

    public init(
        environment: SdkEnvironment,
        clientName: String,
        apiVersion: String = "v2",
        clientId: String,
        clientSecret: String,
        awsWafToken: String = "",
        enableLogging: Bool = false,
        enableCaching: Bool = true,
        defaultCacheTTL: TimeInterval = 3600,
        customHeadersProvider: (() async -> [String: String])? = nil
    ) {
        self.environment = environment
        self.clientName = clientName
        self.apiVersion = apiVersion
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.awsWafToken = awsWafToken
        self.enableLogging = enableLogging
        self.enableCaching = enableCaching
        self.defaultCacheTTL = defaultCacheTTL
        self.customHeadersProvider = customHeadersProvider
    }

    var baseURL: String {
        switch environment {
        case .staging:
            return "https://\(clientName).stage.esimplified.io"
        case .production:
            return "https://\(clientName).live.esimplified.io"
        }
    }
}
