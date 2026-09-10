//
//  LegalContentParser.swift
//  EsimplifiedSDK
//  Created by Zivaiishe Kanengoni on 2026/09/09.
//

import Foundation

// MARK: Policy Group

public enum PolicyGroup: Hashable, Sendable {
    case paragraph(String)
    case heading(String)
    case list([String])
}

// MARK: Terms Node

public struct TermsNode: Hashable, Sendable {

    public let text: String
    public let children: [TermsNode]

    public init(text: String, children: [TermsNode] = []) {
        self.text = text
        self.children = children
    }
}

// MARK: Legal Content Parser

public enum LegalContentParser {

    // MARK: Terms

    static func termsDocument(from raw: RawLegalContent) -> TermsDocument {
        let sections = TermsOutline.sectionIds.compactMap { id -> TermsSection? in
            guard let section = raw.sections[id] else { return nil }
            let lines = lines(of: section, keys: TermsOutline.bodyKeys[id] ?? [])
            let depths = TermsOutline.itemDepths[id] ?? []
            let aligned = lines.count == depths.count
            let items = lines.enumerated().map { offset, text in
                TermsItem(depth: aligned ? depths[offset] : 1, text: text)
            }
            return TermsSection(
                id: id,
                title: section["title"] ?? id,
                items: items,
                sublistMarker: TermsOutline.sublistMarkers[id] ?? .disc
            )
        }
        return TermsDocument(title: raw.title ?? "", tocLabel: raw.onThisPage ?? "", sections: sections)
    }

    public static func termsTree(_ items: [TermsItem]) -> [TermsNode] {
        let root = MutableNode(text: "")
        var openAt: [Int: MutableNode] = [0: root]
        for item in items {
            let node = MutableNode(text: item.text)
            (openAt[item.depth - 1] ?? root).children.append(node)
            openAt[item.depth] = node
        }
        return root.children.map { $0.frozen() }
    }

    // MARK: Privacy

    static func privacyDocument(from raw: RawLegalContent) -> PrivacyDocument {
        let sections = PrivacyOutline.sectionIds.compactMap { id -> PolicySection? in
            guard let section = raw.sections[id] else { return nil }
            let lines = lines(of: section, keys: PrivacyOutline.bodyKeys[id] ?? [])
            let kinds = PrivacyOutline.blockKinds[id] ?? []
            let aligned = lines.count == kinds.count
            let blocks = lines.enumerated().map { offset, text in
                PolicyBlock(kind: aligned ? kinds[offset] : .paragraph, text: text)
            }
            return PolicySection(id: id, title: section["title"] ?? id, blocks: blocks)
        }
        return PrivacyDocument(
            title: raw.title ?? "",
            tocLabel: raw.onThisPage ?? "",
            lastUpdated: raw.lastUpdated,
            sections: sections
        )
    }

    public static func groups(_ blocks: [PolicyBlock]) -> [PolicyGroup] {
        var groups: [PolicyGroup] = []
        for block in blocks {
            switch block.kind {
            case .listItem:
                if case .list(let items)? = groups.last {
                    groups[groups.count - 1] = .list(items + [block.text])
                } else {
                    groups.append(.list([block.text]))
                }
            case .heading:
                groups.append(.heading(block.text))
            case .paragraph:
                groups.append(.paragraph(block.text))
            }
        }
        return groups
    }

    // MARK: Helpers

    private static func lines(of section: [String: String], keys: [String]) -> [String] {
        keys.compactMap { section[$0] }
            .joined(separator: "\n")
            .components(separatedBy: "\n")
    }

    private final class MutableNode {
        let text: String
        var children: [MutableNode] = []

        init(text: String) {
            self.text = text
        }

        func frozen() -> TermsNode {
            TermsNode(text: text, children: children.map { $0.frozen() })
        }
    }
}
