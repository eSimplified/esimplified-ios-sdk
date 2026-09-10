//
//  ContentEnvelopeDecodingTests.swift
//  EsimplifiedSDK
//  Created by Zivaiishe Kanengoni on 2026/09/09.
//

import Testing
import Foundation
@testable import EsimplifiedSDK

@Suite("Content Envelope Decoding")
struct ContentEnvelopeDecodingTests {

    @Test("FAQ envelopes decode with their language", arguments: ["en", "ar"])
    func faqsEnvelope(language: String) throws {
        let envelope = try Fixtures.faqs(language)
        #expect(envelope.language == language)
        #expect(envelope.content.article.count == 62)
        #expect(envelope.content.category.count == 6)
        #expect(Set(envelope.content.category.keys) == Set(SupportCatalog.categories.map(\.id)))
    }

    @Test("Terms envelopes decode with their language", arguments: ["en", "ar"])
    func termsEnvelope(language: String) throws {
        let envelope = try Fixtures.legal("terms", language)
        #expect(envelope.language == language)
        #expect(envelope.content.title != nil)
        #expect(envelope.content.onThisPage != nil)
        #expect(envelope.content.lastUpdated == nil)
        #expect(Set(envelope.content.sections.keys) == Set(TermsOutline.sectionIds))
    }

    @Test("Privacy envelope decodes with lastUpdated")
    func privacyEnvelope() throws {
        let envelope = try Fixtures.legal("privacy", "en")
        #expect(envelope.language == "en")
        #expect(envelope.content.lastUpdated == "Last updated: 28 April 2025")
        #expect(Set(envelope.content.sections.keys) == Set(PrivacyOutline.sectionIds))
    }

    @Test("FaqArticleValue decodes strings and dictionaries")
    func articleValueUnion() throws {
        let json = #"{"title":"T","b1":{"heading":"","p1":"x"}}"#
        let entry = try JSONDecoder().decode([String: FaqArticleValue].self, from: Data(json.utf8))
        #expect(entry["title"] == .text("T"))
        #expect(entry["b1"] == .block(["heading": "", "p1": "x"]))
    }

    @Test("FaqArticleValue rejects non-string leaves")
    func articleValueRejects() {
        let json = #"{"b1":{"p1":1}}"#
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode([String: FaqArticleValue].self, from: Data(json.utf8))
        }
    }
}
