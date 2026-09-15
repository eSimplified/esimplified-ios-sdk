//
//  ContentDocumentDecodingTests.swift
//  EsimplifiedSDK
//  Created by Zivaiishe Kanengoni on 2026/09/15.
//

import Testing
import Foundation
@testable import EsimplifiedSDK

@Suite("ContentDocument decoding")
struct ContentDocumentDecodingTests {

    private func child(_ id: String, in document: ContentDocument) -> ContentNode? {
        document.children.first { $0.id == id }
    }

    // MARK: Terms

    @Test("Terms: en and ar decode 9 sections with a title", arguments: ["en", "ar"])
    func termsSections(language: String) throws {
        let document = try Fixtures.content("terms_\(language)")
        #expect(document.language == language)
        #expect(document.title?.isEmpty == false)
        #expect(document.updatedAt == nil)
        #expect(document.blocks.isEmpty)
        #expect(document.children.count == 9)
        for section in document.children where section.id != "kreds" {
            #expect(section.blocks.count == 1)
            guard case .list? = section.blocks.first else {
                Issue.record("expected a list block in \(section.id ?? "?")")
                continue
            }
        }
    }

    @Test("Terms: kreds section carries 27 blocks including headings")
    func termsKreds() throws {
        let document = try Fixtures.content("terms_en")
        let kreds = try #require(child("kreds", in: document))
        #expect(kreds.blocks.count == 27)
        #expect(kreds.blocks[1] == .heading("Earning Kreds"))
        guard case .paragraph(let text)? = kreds.blocks.first else {
            Issue.record("expected a leading paragraph")
            return
        }
        #expect(text.contains("Kreds"))
    }

    @Test("Terms: eligibility is a decimal list whose first item nests four bullets")
    func termsEligibility() throws {
        let document = try Fixtures.content("terms_en")
        let eligibility = try #require(child("eligibility", in: document))
        guard case .list(let list)? = eligibility.blocks.first else {
            Issue.record("expected a list block")
            return
        }
        #expect(list.ordered)
        #expect(list.marker == .decimal)
        #expect(list.items.count == 3)
        let first = try #require(list.items.first)
        #expect(first.items.count == 4)
        #expect(first.ordered == false)
        #expect(first.marker == .bullet)
        #expect(list.items[1].items.isEmpty)
        #expect(list.items[1].ordered == nil)
        #expect(list.items[1].marker == nil)
    }

    // MARK: Privacy

    @Test("Privacy: en and ar decode 14 sections with updatedAt", arguments: ["en", "ar"])
    func privacySections(language: String) throws {
        let document = try Fixtures.content("privacy_\(language)")
        #expect(document.language == language)
        #expect(document.children.count == 14)
        #expect(document.updatedAt?.isEmpty == false)
        #expect(document.children.allSatisfy { $0.children.isEmpty })
        #expect(document.children.allSatisfy { !$0.blocks.isEmpty })
    }

    @Test("Privacy: en updatedAt is the last-updated line")
    func privacyUpdatedAt() throws {
        let document = try Fixtures.content("privacy_en")
        #expect(document.title == "Privacy Policy")
        #expect(document.updatedAt == "Last updated: 28 April 2025")
    }

    // MARK: FAQs

    @Test("FAQs: en and ar decode 6 categories and 62 articles", arguments: ["en", "ar"])
    func faqsTree(language: String) throws {
        let document = try Fixtures.content("faqs_\(language)")
        #expect(document.language == language)
        #expect(document.title == nil)
        #expect(document.children.count == 6)
        let articles = document.children.flatMap(\.children)
        #expect(articles.count == 62)
        #expect(articles.allSatisfy { !$0.blocks.isEmpty })
        #expect(articles.allSatisfy { $0.id?.isEmpty == false && $0.title?.isEmpty == false })
    }

    @Test("FAQs: an article block is an ordered decimal list with nested items")
    func faqsNestedList() throws {
        let document = try Fixtures.content("faqs_en")
        let general = try #require(child("general", in: document))
        let article = try #require(general.children.first { $0.id == "are-esims-safe-and-secure-to-use" })
        guard case .list(let list) = article.blocks[6] else {
            Issue.record("expected a list block")
            return
        }
        #expect(list.ordered)
        #expect(list.marker == .decimal)
        #expect(list.items.count == 2)
        #expect(list.items[0].text == "Remote Deactivation")
        #expect(list.items[0].items.count == 1)
        #expect(list.items[0].marker == .bullet)
    }

    // MARK: Forward compatibility

    @Test("Unknown block type decodes to .unknown")
    func unknownBlock() throws {
        let json = #"[{"type":"table","rows":[]},{"type":"paragraph","text":"p"}]"#
        let blocks = try JSONDecoder().decode([ContentBlock].self, from: Data(json.utf8))
        #expect(blocks == [.unknown, .paragraph("p")])
    }

    @Test("Unknown list marker falls back to .bullet")
    func unknownMarker() throws {
        let json = #"{"type":"list","ordered":false,"marker":"roman","items":[]}"#
        let block = try JSONDecoder().decode(ContentBlock.self, from: Data(json.utf8))
        #expect(block == .list(ContentList(ordered: false, marker: .bullet, items: [])))
    }

    // MARK: Round trip

    @Test("Encoding then decoding a document is lossless")
    func roundTrip() throws {
        let document = try Fixtures.content("terms_en")
        let data = try JSONEncoder().encode(document)
        let decoded = try JSONDecoder().decode(ContentDocument.self, from: data)
        #expect(decoded == document)
    }

    @Test("Unknown blocks survive a round trip")
    func unknownRoundTrip() throws {
        let node = ContentNode(id: "x", blocks: [.unknown, .heading("h")])
        let data = try JSONEncoder().encode(node)
        let decoded = try JSONDecoder().decode(ContentNode.self, from: data)
        #expect(decoded == node)
    }
}
