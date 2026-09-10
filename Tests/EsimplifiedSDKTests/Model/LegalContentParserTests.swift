//
//  LegalContentParserTests.swift
//  EsimplifiedSDK
//  Created by Zivaiishe Kanengoni on 2026/09/09.
//

import Testing
import Foundation
@testable import EsimplifiedSDK

@Suite("Legal Content Parser")
struct LegalContentParserTests {

    private func terms(_ language: String = "en") throws -> TermsDocument {
        LegalContentParser.termsDocument(from: try Fixtures.legal("terms", language).content)
    }

    private func privacy() throws -> PrivacyDocument {
        LegalContentParser.privacyDocument(from: try Fixtures.legal("privacy", "en").content)
    }

    private func section(_ id: String, in document: TermsDocument) throws -> TermsSection {
        try #require(document.sections.first { $0.id == id })
    }

    // MARK: Terms

    @Test("terms_en yields 9 sections in outline order")
    func englishTermsSections() throws {
        let document = try terms()
        #expect(document.title == "Terms and conditions")
        #expect(!document.tocLabel.isEmpty)
        #expect(document.sections.map(\.id) == TermsOutline.sectionIds)
        #expect(document.sections.count == 9)
        #expect(document.sections.allSatisfy { !$0.title.isEmpty && !$0.items.isEmpty })
    }

    @Test("terms_ar yields 9 sections in outline order")
    func arabicTermsSections() throws {
        let document = try terms("ar")
        #expect(document.sections.map(\.id) == TermsOutline.sectionIds)
        #expect(document.sections.count == 9)
    }

    @Test("Eligibility has 7 items with the outline depths")
    func eligibilityDepths() throws {
        let section = try section("eligibility", in: try terms())
        #expect(section.items.count == 7)
        #expect(section.items.map(\.depth) == [1, 2, 2, 2, 2, 1, 1])
        #expect(section.items[0].text.hasPrefix("Access to Benefits"))
        #expect(section.sublistMarker == .disc)
    }

    @Test("General terms items are all depth 1 and match the outline count")
    func generalTermsDepths() throws {
        let section = try section("generalTerms", in: try terms())
        #expect(section.items.count == 22)
        #expect(section.items.count == TermsOutline.itemDepths["generalTerms"]?.count)
        #expect(section.items.allSatisfy { $0.depth == 1 })
    }

    @Test("Every live section aligns with its outline depths")
    func liveSectionsAlign() throws {
        for section in try terms().sections {
            #expect(section.items.map(\.depth) == TermsOutline.itemDepths[section.id], "\(section.id)")
            #expect(section.sublistMarker == TermsOutline.sublistMarkers[section.id])
        }
    }

    @Test("A section whose line count mismatches the outline flattens to depth 1")
    func mismatchFlattens() {
        let raw = RawLegalContent(
            title: "Terms",
            onThisPage: "On this page",
            sections: [
                "eligibility": ["title": "Eligibility", "body1": "One\nTwo\nThree"],
                "vouchers": ["title": "Vouchers", "body1": "First\nSecond"]
            ]
        )
        let document = LegalContentParser.termsDocument(from: raw)
        #expect(document.sections.map(\.id) == ["eligibility", "vouchers"])
        #expect(document.sections[0].items.map(\.depth) == [1, 1, 1])
        #expect(document.sections[0].items.map(\.text) == ["One", "Two", "Three"])
        #expect(document.sections[1].items.map(\.depth) == [1, 1])
    }

    @Test("Multiple body keys are joined before splitting")
    func bodiesJoin() {
        let raw = RawLegalContent(sections: [
            "generalTerms": ["title": "General", "body1": "First\nSecond", "body2": "Third", "body3": "Fourth"],
            "vouchers": ["title": "Vouchers", "body1": "Only", "body2": "Ignored"]
        ])
        let document = LegalContentParser.termsDocument(from: raw)
        #expect(document.title == "")
        #expect(document.sections[0].items.map(\.text) == ["First", "Second", "Third", "Fourth"])
        #expect(document.sections[0].items.map(\.depth) == [1, 1, 1, 1])
        #expect(document.sections[1].items.map(\.text) == ["Only"])
    }

    @Test("Terms tree nests by depth")
    func termsTree() {
        let items = [
            TermsItem(depth: 1, text: "A"),
            TermsItem(depth: 2, text: "A.a"),
            TermsItem(depth: 3, text: "A.a.i"),
            TermsItem(depth: 3, text: "A.a.ii"),
            TermsItem(depth: 2, text: "A.b"),
            TermsItem(depth: 1, text: "B"),
            TermsItem(depth: 2, text: "B.a")
        ]
        let tree = LegalContentParser.termsTree(items)
        #expect(tree.map(\.text) == ["A", "B"])
        #expect(tree[0].children.map(\.text) == ["A.a", "A.b"])
        #expect(tree[0].children[0].children.map(\.text) == ["A.a.i", "A.a.ii"])
        #expect(tree[0].children[1].children.isEmpty)
        #expect(tree[1].children.map(\.text) == ["B.a"])
    }

    @Test("Terms tree on the live eligibility section nests the four steps")
    func liveEligibilityTree() throws {
        let section = try section("eligibility", in: try terms())
        let tree = LegalContentParser.termsTree(section.items)
        #expect(tree.count == 3)
        #expect(tree[0].children.count == 4)
        #expect(tree[1].children.isEmpty)
        #expect(tree[2].children.isEmpty)
    }

    @Test("Terms tree drops a depth-2 item with no open parent to the roots")
    func termsTreeOrphan() {
        let tree = LegalContentParser.termsTree([TermsItem(depth: 2, text: "Orphan"), TermsItem(depth: 1, text: "Root")])
        #expect(tree.map(\.text) == ["Orphan", "Root"])
    }

    // MARK: Privacy

    @Test("privacy_en yields sections in outline order with lastUpdated")
    func privacySections() throws {
        let document = try privacy()
        #expect(document.title == "Privacy Policy")
        #expect(!document.tocLabel.isEmpty)
        #expect(document.lastUpdated != nil)
        #expect(document.sections.map(\.id) == PrivacyOutline.sectionIds)
        #expect(document.sections.count == 14)
    }

    @Test("Privacy sections align with the outline kinds")
    func privacyKinds() throws {
        let document = try privacy()
        let collected = try #require(document.sections.first { $0.id == "whatWeCollect" })
        #expect(collected.blocks.map(\.kind) == PrivacyOutline.blockKinds["whatWeCollect"])
        #expect(collected.blocks.count == 16)
        for section in document.sections {
            #expect(section.blocks.map(\.kind) == PrivacyOutline.blockKinds[section.id], "\(section.id)")
        }
    }

    @Test("Privacy count mismatch flattens to paragraphs")
    func privacyMismatch() {
        let raw = RawLegalContent(
            title: "Privacy",
            lastUpdated: "Last updated: today",
            sections: ["howWeUse": ["title": "Use", "body1": "Only one line"]]
        )
        let document = LegalContentParser.privacyDocument(from: raw)
        #expect(document.lastUpdated == "Last updated: today")
        #expect(document.sections.count == 1)
        #expect(document.sections[0].blocks.map(\.kind) == [.paragraph])
    }

    @Test("Groups coalesce consecutive list items")
    func groupsCoalesce() {
        let blocks = [
            PolicyBlock(kind: .paragraph, text: "Intro"),
            PolicyBlock(kind: .listItem, text: "One"),
            PolicyBlock(kind: .listItem, text: "Two"),
            PolicyBlock(kind: .heading, text: "Head"),
            PolicyBlock(kind: .listItem, text: "Three"),
            PolicyBlock(kind: .paragraph, text: "Outro")
        ]
        #expect(LegalContentParser.groups(blocks) == [
            .paragraph("Intro"),
            .list(["One", "Two"]),
            .heading("Head"),
            .list(["Three"]),
            .paragraph("Outro")
        ])
    }

    @Test("Groups on the live howWeUse section produce a paragraph and one list of four")
    func liveGroups() throws {
        let section = try #require(try privacy().sections.first { $0.id == "howWeUse" })
        let groups = LegalContentParser.groups(section.blocks)
        #expect(groups.count == 2)
        #expect(groups[1] == .list(section.blocks.dropFirst().map(\.text)))
    }
}
