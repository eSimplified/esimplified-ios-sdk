//
//  LegalContentParser.swift
//  EsimplifiedSDK
//  Created by Zivaiishe Kanengoni on 2026/09/09.
//

import Foundation

extension LegalContentParser {

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

    // MARK: Helpers

    private static func lines(of section: [String: String], keys: [String]) -> [String] {
        keys.compactMap { section[$0] }
            .joined(separator: "\n")
            .components(separatedBy: "\n")
    }
}
