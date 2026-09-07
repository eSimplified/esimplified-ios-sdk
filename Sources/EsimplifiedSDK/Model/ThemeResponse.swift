//
//  ThemeResponse.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/09/07.
//

import Foundation

// MARK: Page Theme

public struct PageTheme: Codable, Hashable, Sendable {
    public let version: String?
    public let cdnBase: String?
    public let pages: [String: ThemePage]
    public let destinations: [String: ThemeDestination]

    public init(
        version: String? = nil,
        cdnBase: String? = nil,
        pages: [String: ThemePage] = [:],
        destinations: [String: ThemeDestination] = [:]
    ) {
        self.version = version
        self.cdnBase = cdnBase
        self.pages = pages
        self.destinations = destinations
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        version = try container.decodeIfPresent(String.self, forKey: .version)
        cdnBase = try container.decodeIfPresent(String.self, forKey: .cdnBase)
        pages = try container.decodeIfPresent([String: ThemePage].self, forKey: .pages) ?? [:]
        destinations = try container.decodeIfPresent([String: ThemeDestination].self, forKey: .destinations) ?? [:]
    }

    public func page(_ name: String) -> ThemePage? {
        pages[name]
    }

    public func destination(_ slug: String) -> ThemeDestination? {
        destinations[slug]
    }
}

// MARK: Theme Page

public struct ThemePage: Codable, Hashable, Sendable {
    public let urlPath: String?
    public let featuredImage: ThemeImage?
    public let color: String?

    public init(urlPath: String? = nil, featuredImage: ThemeImage? = nil, color: String? = nil) {
        self.urlPath = urlPath
        self.featuredImage = featuredImage
        self.color = color
    }
}

// MARK: Theme Image

public struct ThemeImage: Codable, Hashable, Sendable {
    public let url: String
    public let accent: String?

    public init(url: String, accent: String? = nil) {
        self.url = url
        self.accent = accent
    }
}

// MARK: Theme Destination

public struct ThemeDestination: Codable, Hashable, Sendable {
    public let image: ThemeImage?
    public let gallery: [String]?
    public let countryCode: String?

    public init(image: ThemeImage? = nil, gallery: [String]? = nil, countryCode: String? = nil) {
        self.image = image
        self.gallery = gallery
        self.countryCode = countryCode
    }
}
