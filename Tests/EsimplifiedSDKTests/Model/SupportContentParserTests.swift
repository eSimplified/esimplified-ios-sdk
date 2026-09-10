//
//  SupportContentParserTests.swift
//  EsimplifiedSDK
//  Created by Zivaiishe Kanengoni on 2026/09/09.
//

import Testing
import Foundation
@testable import EsimplifiedSDK

@Suite("Support Content Parser")
struct SupportContentParserTests {

    private static let catalogOrder = ["about", "installation", "general", "pricing", "troubleshooting", "programs"]

    private func sections(_ language: String = "en") throws -> [SupportSection] {
        SupportContentParser.normalize(try Fixtures.faqs(language).content)
    }

    private func article(_ slug: String, in sections: [SupportSection]) throws -> SupportArticle {
        try #require(sections.flatMap(\.articles).first { $0.slug == slug })
    }

    @Test("faqs_en normalizes to 62 articles across 6 sections in catalog order")
    func englishCounts() throws {
        let sections = try sections()
        #expect(sections.count == 6)
        #expect(sections.map(\.slug) == Self.catalogOrder)
        #expect(sections.flatMap(\.articles).count == 62)
        #expect(sections.map(\.articles.count) == [9, 10, 16, 10, 5, 12])
        #expect(sections.allSatisfy { !$0.title.isEmpty && !$0.description.isEmpty })
    }

    @Test("faqs_ar normalizes to the same 62 articles across 6 sections")
    func arabicCounts() throws {
        let sections = try sections("ar")
        #expect(sections.count == 6)
        #expect(sections.map(\.slug) == Self.catalogOrder)
        #expect(sections.flatMap(\.articles).count == 62)
    }

    @Test("Catalog holds 6 categories and 62 unique slugs")
    func catalogShape() {
        let slugs = SupportCatalog.categories.flatMap(\.articles)
        #expect(SupportCatalog.categories.map(\.id) == Self.catalogOrder)
        #expect(slugs.count == 62)
        #expect(Set(slugs).count == 62)
    }

    @Test("Safe-and-secure article b3 has ordered steps with one sub-item each")
    func safeAndSecureSteps() throws {
        let article = try article("are-esims-safe-and-secure-to-use", in: try sections())
        let block = article.body[2]
        let list = try #require(block.list)
        #expect(block.heading == "Encrypted provisioning")
        #expect(block.paragraphs.count == 1)
        #expect(list.isOrdered)
        #expect(list.items.count == 2)
        #expect(list.items[0].text == "Remote Deactivation")
        #expect(list.items[0].subItems.count == 1)
        #expect(list.items[1].text == "No Tampering Risk")
        #expect(list.items[1].subItems.count == 1)
    }

    @Test("Network-locked article b2 step 2 has two sub-items")
    func networkLockedSubItems() throws {
        let article = try article("what-do-i-do-if-my-device-is-network-locked", in: try sections())
        let list = try #require(article.body[1].list)
        #expect(list.isOrdered)
        #expect(list.items.count == 2)
        #expect(list.items[0].subItems.isEmpty)
        #expect(list.items[1].subItems.count == 2)
        #expect(list.items[1].subItems[0].hasPrefix("Insert a different carrier"))
    }

    @Test("Dual-SIM summary has three paragraphs and a bulleted list of three")
    func dualSimSummary() throws {
        let article = try article("can-i-use-an-esim-and-physical-sim-at-the-same-time-dual-sim", in: try sections())
        let list = try #require(article.summary.list)
        #expect(article.title == "Can I use an eSIM and physical SIM at the same time (dual SIM)?")
        #expect(article.summary.heading == nil)
        #expect(article.summary.paragraphs.count == 3)
        #expect(!list.isOrdered)
        #expect(list.items.count == 3)
        #expect(list.items.allSatisfy { $0.subItems.isEmpty })
        #expect(article.body.count == 1)
    }

    @Test("A block with both sN and uN keys is ordered")
    func orderedWinsOverBullets() {
        let block = SupportContentParser.readBlock([
            "heading": "Mixed",
            "p1": "Intro",
            "u1": "Bullet one",
            "u2": "Bullet two",
            "s1": "Step one",
            "s2": "Step two"
        ])
        let list = block.list
        #expect(list?.isOrdered == true)
        #expect(list?.items.map(\.text) == ["Step one", "Step two"])
        #expect(block.paragraphs == ["Intro"])
    }

    @Test("Empty heading becomes nil")
    func emptyHeading() {
        #expect(SupportContentParser.readBlock(["heading": "", "p1": "Text"]).heading == nil)
        #expect(SupportContentParser.readBlock(["p1": "Text"]).heading == nil)
        #expect(SupportContentParser.readBlock(["heading": "Title", "p1": "Text"]).heading == "Title")
    }

    @Test("Keys sort by first digit run and non-numeric keys fall to the end")
    func indexOrdering() {
        #expect(SupportContentParser.index(of: "p10") == 10)
        #expect(SupportContentParser.index(of: "s2sub7") == 2)
        #expect(SupportContentParser.index(of: "heading") == Int.max)
        #expect(SupportContentParser.sortedByIndex(["p10", "p2", "heading", "p1"]) == ["p1", "p2", "p10", "heading"])

        let block = SupportContentParser.readBlock(["p10": "ten", "p2": "two", "p1": "one"])
        #expect(block.paragraphs == ["one", "two", "ten"])
    }

    @Test("Sub-items sort by trailing integer and stay under their step")
    func subItemOrdering() {
        let source = [
            "s1": "Step one",
            "s1sub10": "ten",
            "s1sub2": "two",
            "s1sub1": "one",
            "s2": "Step two",
            "s2sub1": "other",
            "s10": "Step ten",
            "s10sub1": "tenth"
        ]
        #expect(SupportContentParser.subItems(for: "s1", in: source) == ["one", "two", "ten"])
        #expect(SupportContentParser.subItems(for: "s2", in: source) == ["other"])
        #expect(SupportContentParser.subItems(for: "s10", in: source) == ["tenth"])

        let block = SupportContentParser.readBlock(source)
        #expect(block.list?.items.map(\.text) == ["Step one", "Step two", "Step ten"])
        #expect(block.list?.items[0].subItems == ["one", "two", "ten"])
        #expect(block.paragraphs.isEmpty)
    }

    @Test("Popular articles round-robin the catalog")
    func popularArticles() throws {
        let sections = try sections()
        let popular = SupportContentParser.popularArticles(in: sections, limit: 8)
        #expect(popular.count == 8)
        #expect(popular.map(\.section.slug) == Self.catalogOrder + ["about", "installation"])
        #expect(popular.prefix(6).map(\.article.slug) == sections.map { $0.articles[0].slug })
        #expect(popular[6].article.slug == sections[0].articles[1].slug)
        #expect(popular[7].article.slug == sections[1].articles[1].slug)
    }

    @Test("Popular stops when sections run out of articles")
    func popularExhausts() throws {
        let sections = try sections()
        #expect(SupportContentParser.popularArticles(in: sections, limit: 100).count == 62)
        #expect(SupportContentParser.popularArticles(in: [], limit: 3).isEmpty)
    }

    @Test("Missing categories and articles are skipped silently")
    func skipsMissing() {
        let raw = RawFaqsContent(
            category: ["installation": FaqCategoryMeta(title: "Install", description: "Setup")],
            article: [
                "how-to-label-your-esim": ["title": .text("Label"), "p1": .text("Body")],
                "unknown-slug": ["title": .text("Nope")]
            ]
        )
        let sections = SupportContentParser.normalize(raw)
        #expect(sections.count == 1)
        #expect(sections[0].slug == "installation")
        #expect(sections[0].articles.map(\.slug) == ["how-to-label-your-esim"])
        #expect(sections[0].articles[0].summary.paragraphs == ["Body"])
    }

    @Test("Article without a title falls back to its slug")
    func titleFallback() {
        let raw = RawFaqsContent(
            category: ["about": FaqCategoryMeta(title: "About", description: "")],
            article: ["what-is-an-esim": ["p1": .text("An eSIM.")]]
        )
        let article = SupportContentParser.normalize(raw)[0].articles[0]
        #expect(article.title == "what-is-an-esim")
    }
}
