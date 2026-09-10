//
//  LegalContent.swift
//  EsimplifiedSDK
//  Created by Zivaiishe Kanengoni on 2026/09/09.
//

import Foundation

// MARK: Policy Block Kind

public enum PolicyBlockKind: String, Codable, Hashable, Sendable {
    case paragraph = "p"
    case heading = "h"
    case listItem = "li"
}

// MARK: Policy Block

public struct PolicyBlock: Codable, Hashable, Sendable {

    public let kind: PolicyBlockKind
    public let text: String

    public init(kind: PolicyBlockKind, text: String) {
        self.kind = kind
        self.text = text
    }
}

// MARK: Terms Item

public struct TermsItem: Codable, Hashable, Sendable {

    public let depth: Int
    public let text: String

    public init(depth: Int, text: String) {
        self.depth = depth
        self.text = text
    }
}

// MARK: Terms Sublist Marker

public enum TermsSublistMarker: String, Codable, Hashable, Sendable {
    case alpha
    case disc
}

// MARK: Terms Section

public struct TermsSection: Codable, Hashable, Sendable {

    public let id: String
    public let title: String
    public let items: [TermsItem]
    public let sublistMarker: TermsSublistMarker

    public init(id: String, title: String, items: [TermsItem], sublistMarker: TermsSublistMarker) {
        self.id = id
        self.title = title
        self.items = items
        self.sublistMarker = sublistMarker
    }
}

// MARK: Terms Document

public struct TermsDocument: Codable, Hashable, Sendable {

    public let title: String
    public let tocLabel: String
    public let sections: [TermsSection]

    public init(title: String, tocLabel: String, sections: [TermsSection]) {
        self.title = title
        self.tocLabel = tocLabel
        self.sections = sections
    }
}

// MARK: Policy Section

public struct PolicySection: Codable, Hashable, Sendable {

    public let id: String
    public let title: String
    public let blocks: [PolicyBlock]

    public init(id: String, title: String, blocks: [PolicyBlock]) {
        self.id = id
        self.title = title
        self.blocks = blocks
    }
}

// MARK: Privacy Document

public struct PrivacyDocument: Codable, Hashable, Sendable {

    public let title: String
    public let tocLabel: String
    public let lastUpdated: String?
    public let sections: [PolicySection]

    public init(title: String, tocLabel: String, lastUpdated: String? = nil, sections: [PolicySection]) {
        self.title = title
        self.tocLabel = tocLabel
        self.lastUpdated = lastUpdated
        self.sections = sections
    }
}

// MARK: Raw Legal Content

struct RawLegalContent: Decodable, Hashable, Sendable {

    let title: String?
    let onThisPage: String?
    let lastUpdated: String?
    let sections: [String: [String: String]]

    init(
        title: String? = nil,
        onThisPage: String? = nil,
        lastUpdated: String? = nil,
        sections: [String: [String: String]]
    ) {
        self.title = title
        self.onThisPage = onThisPage
        self.lastUpdated = lastUpdated
        self.sections = sections
    }
}
