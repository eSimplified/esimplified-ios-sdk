//
//  SupportContent.swift
//  EsimplifiedSDK
//  Created by Zivaiishe Kanengoni on 2026/09/09.
//

import Foundation

// MARK: Support Section

public struct SupportSection: Codable, Hashable, Sendable {

    public let slug: String
    public let title: String
    public let description: String
    public let articles: [SupportArticle]

    public init(slug: String, title: String, description: String, articles: [SupportArticle]) {
        self.slug = slug
        self.title = title
        self.description = description
        self.articles = articles
    }
}

// MARK: Support Article

public struct SupportArticle: Codable, Hashable, Sendable {

    public let slug: String
    public let title: String
    public let summary: SupportBlock
    public let body: [SupportBlock]

    public init(slug: String, title: String, summary: SupportBlock, body: [SupportBlock]) {
        self.slug = slug
        self.title = title
        self.summary = summary
        self.body = body
    }
}

// MARK: Support Block

public struct SupportBlock: Codable, Hashable, Sendable {

    public let heading: String?
    public let paragraphs: [String]
    public let list: SupportList?

    public init(heading: String? = nil, paragraphs: [String], list: SupportList? = nil) {
        self.heading = heading
        self.paragraphs = paragraphs
        self.list = list
    }
}

// MARK: Support List

public struct SupportList: Codable, Hashable, Sendable {

    public let isOrdered: Bool
    public let items: [SupportListItem]

    public init(isOrdered: Bool, items: [SupportListItem]) {
        self.isOrdered = isOrdered
        self.items = items
    }
}

// MARK: Support List Item

public struct SupportListItem: Codable, Hashable, Sendable {

    public let text: String
    public let subItems: [String]

    public init(text: String, subItems: [String] = []) {
        self.text = text
        self.subItems = subItems
    }
}

// MARK: Raw FAQs Content

struct RawFaqsContent: Decodable, Hashable, Sendable {

    let category: [String: FaqCategoryMeta]
    let article: [String: [String: FaqArticleValue]]
}

// MARK: FAQ Category Meta

struct FaqCategoryMeta: Decodable, Hashable, Sendable {

    let title: String
    let description: String
}

// MARK: FAQ Article Value

enum FaqArticleValue: Decodable, Hashable, Sendable {

    case text(String)
    case block([String: String])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let text = try? container.decode(String.self) {
            self = .text(text)
        } else {
            self = .block(try container.decode([String: String].self))
        }
    }
}
