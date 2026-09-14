//
//  SupportContentParser.swift
//  EsimplifiedSDK
//  Created by Zivaiishe Kanengoni on 2026/09/09.
//

import Foundation

extension SupportContentParser {

    // MARK: Normalisation

    static func normalize(_ raw: RawFaqsContent) -> [SupportSection] {
        SupportCatalog.categories.compactMap { category in
            guard let meta = raw.category[category.id] else { return nil }

            let articles = category.articles.compactMap { slug -> SupportArticle? in
                guard let entry = raw.article[slug] else { return nil }

                var title = slug
                var flat: [String: String] = [:]
                var blocks: [String: [String: String]] = [:]
                for (key, value) in entry {
                    switch value {
                    case .text(let text):
                        if key == "title" {
                            title = text
                        } else {
                            flat[key] = text
                        }
                    case .block(let block):
                        if matches(key, prefix: "b") {
                            blocks[key] = block
                        }
                    }
                }

                let summary = readBlock(flat)
                let body = sortedByIndex(Array(blocks.keys)).compactMap { blocks[$0] }.map(readBlock)
                return SupportArticle(slug: slug, title: title, summary: summary, body: body)
            }

            return SupportSection(
                slug: category.id,
                title: meta.title,
                description: meta.description,
                articles: articles
            )
        }
    }

    // MARK: Blocks

    static func readBlock(_ source: [String: String]) -> SupportBlock {
        var paragraphs: [String] = []
        var ordered: [SupportListItem] = []
        var bullets: [SupportListItem] = []

        for key in sortedByIndex(Array(source.keys)) {
            guard key != "heading", let value = source[key] else { continue }
            if matches(key, prefix: "p") {
                paragraphs.append(value)
            } else if matches(key, prefix: "s") {
                ordered.append(SupportListItem(text: value, subItems: subItems(for: key, in: source)))
            } else if matches(key, prefix: "u") {
                bullets.append(SupportListItem(text: value, subItems: subItems(for: key, in: source)))
            }
        }

        var list: SupportList?
        if !ordered.isEmpty {
            list = SupportList(isOrdered: true, items: ordered)
        } else if !bullets.isEmpty {
            list = SupportList(isOrdered: false, items: bullets)
        }

        let heading = source["heading"].flatMap { $0.isEmpty ? nil : $0 }
        return SupportBlock(heading: heading, paragraphs: paragraphs, list: list)
    }

    // MARK: Key Ordering

    static func index(of key: String) -> Int {
        guard let start = key.firstIndex(where: \.isNumber) else { return Int.max }
        let end = key[start...].firstIndex(where: { !$0.isNumber }) ?? key.endIndex
        return Int(key[start..<end]) ?? Int.max
    }

    static func sortedByIndex(_ keys: [String]) -> [String] {
        keys.sorted { lhs, rhs in
            let left = index(of: lhs)
            let right = index(of: rhs)
            return left == right ? lhs < rhs : left < right
        }
    }

    static func subItems(for itemKey: String, in source: [String: String]) -> [String] {
        let prefix = "\(itemKey)sub"
        return source.keys
            .filter { $0.hasPrefix(prefix) }
            .sorted { lhs, rhs in
                let left = Int(lhs.dropFirst(prefix.count)) ?? Int.max
                let right = Int(rhs.dropFirst(prefix.count)) ?? Int.max
                return left == right ? lhs < rhs : left < right
            }
            .compactMap { source[$0] }
    }

    // MARK: Helpers

    private static func matches(_ key: String, prefix: String) -> Bool {
        guard key.hasPrefix(prefix) else { return false }
        let rest = key.dropFirst(prefix.count)
        return !rest.isEmpty && rest.allSatisfy { $0.isASCII && $0.isNumber }
    }
}
