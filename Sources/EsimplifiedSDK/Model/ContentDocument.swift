//
//  ContentDocument.swift
//  EsimplifiedSDK
//  Created by Zivaiishe Kanengoni on 2026/09/15.
//

import Foundation

// MARK: Content Document

public struct ContentDocument: Codable, Hashable, Sendable {

    public let language: String
    public let id: String?
    public let title: String?
    public let description: String?
    public let updatedAt: String?
    public let blocks: [ContentBlock]
    public let children: [ContentNode]

    public init(
        language: String,
        id: String? = nil,
        title: String? = nil,
        description: String? = nil,
        updatedAt: String? = nil,
        blocks: [ContentBlock] = [],
        children: [ContentNode] = []
    ) {
        self.language = language
        self.id = id
        self.title = title
        self.description = description
        self.updatedAt = updatedAt
        self.blocks = blocks
        self.children = children
    }
}

// MARK: Content Node

public struct ContentNode: Codable, Hashable, Sendable {

    public let id: String?
    public let title: String?
    public let description: String?
    public let updatedAt: String?
    public let blocks: [ContentBlock]
    public let children: [ContentNode]

    public init(
        id: String? = nil,
        title: String? = nil,
        description: String? = nil,
        updatedAt: String? = nil,
        blocks: [ContentBlock] = [],
        children: [ContentNode] = []
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.updatedAt = updatedAt
        self.blocks = blocks
        self.children = children
    }
}

// MARK: Content Block

public enum ContentBlock: Codable, Hashable, Sendable {
    case heading(String)
    case paragraph(String)
    case list(ContentList)
    case unknown

    private enum CodingKeys: String, CodingKey {
        case type
        case text
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(String.self, forKey: .type) {
        case "heading":
            self = .heading(try container.decode(String.self, forKey: .text))
        case "paragraph":
            self = .paragraph(try container.decode(String.self, forKey: .text))
        case "list":
            self = .list(try ContentList(from: decoder))
        default:
            self = .unknown
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .heading(let text):
            try container.encode("heading", forKey: .type)
            try container.encode(text, forKey: .text)
        case .paragraph(let text):
            try container.encode("paragraph", forKey: .type)
            try container.encode(text, forKey: .text)
        case .list(let list):
            try container.encode("list", forKey: .type)
            try list.encode(to: encoder)
        case .unknown:
            try container.encode("unknown", forKey: .type)
        }
    }
}

// MARK: Content List

public struct ContentList: Codable, Hashable, Sendable {

    public let ordered: Bool
    public let marker: ContentListMarker
    public let items: [ContentListItem]

    public init(ordered: Bool, marker: ContentListMarker, items: [ContentListItem]) {
        self.ordered = ordered
        self.marker = marker
        self.items = items
    }
}

// MARK: Content List Marker

public enum ContentListMarker: String, Codable, Hashable, Sendable {
    case decimal
    case alpha
    case bullet

    public init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = ContentListMarker(rawValue: raw) ?? .bullet
    }
}

// MARK: Content List Item

public struct ContentListItem: Codable, Hashable, Sendable {

    public let text: String
    public let items: [ContentListItem]
    public let ordered: Bool?
    public let marker: ContentListMarker?

    public init(
        text: String,
        items: [ContentListItem] = [],
        ordered: Bool? = nil,
        marker: ContentListMarker? = nil
    ) {
        self.text = text
        self.items = items
        self.ordered = ordered
        self.marker = marker
    }
}
