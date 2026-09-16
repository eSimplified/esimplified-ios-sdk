//
//  ContentDocumentDecodingTests.swift
//  EsimplifiedSDK
//  Created by Zivaiishe Kanengoni on 2026/09/15.
//

import Testing
import Foundation
@testable import EsimplifiedSDK

/// A miniature document shaped like the live payloads: a root with an explicit null,
/// a section of blocks and a section whose children nest one level deeper.
private let documentJson = """
{
  "language": "en",
  "id": "terms",
  "title": "Terms of Service",
  "description": null,
  "updatedAt": "Last updated: 28 April 2025",
  "blocks": [],
  "children": [
    {
      "id": "eligibility",
      "title": "Eligibility",
      "description": null,
      "updatedAt": null,
      "blocks": [
        {"type": "heading", "text": "Who can sign up"},
        {"type": "paragraph", "text": "You must be able to hold an account."},
        {
          "type": "list",
          "ordered": true,
          "marker": "decimal",
          "items": [
            {
              "text": "Access to benefits: eligible cardholders must:",
              "items": [
                {"text": "Select your region.", "items": []},
                {"text": "Log in to an account.", "items": []}
              ],
              "ordered": false,
              "marker": "bullet"
            },
            {"text": "Verification happens on entry.", "items": []},
            {"text": "Your device must support eSIM.", "items": []}
          ]
        }
      ],
      "children": []
    },
    {
      "id": "general",
      "title": "General",
      "description": null,
      "updatedAt": null,
      "blocks": [],
      "children": [
        {
          "id": "are-esims-safe",
          "title": "Are eSIMs safe?",
          "description": null,
          "updatedAt": null,
          "blocks": [{"type": "paragraph", "text": "Yes, an eSIM cannot be removed."}],
          "children": []
        }
      ]
    }
  ]
}
"""

@Suite("ContentDocument decoding")
struct ContentDocumentDecodingTests {

    private func decode<T: Decodable>(_ json: String) throws -> T {
        try JSONDecoder().decode(T.self, from: Data(json.utf8))
    }

    private func document() throws -> ContentDocument {
        try decode(documentJson)
    }

    private func child(_ id: String, in document: ContentDocument) -> ContentNode? {
        document.children.first { $0.id == id }
    }

    // MARK: Document

    @Test("Root fields decode, including an explicit null and two levels of children")
    func rootFields() throws {
        let document = try document()
        #expect(document.language == "en")
        #expect(document.id == "terms")
        #expect(document.title == "Terms of Service")
        #expect(document.description == nil)
        #expect(document.updatedAt == "Last updated: 28 April 2025")
        #expect(document.blocks.isEmpty)
        #expect(document.children.count == 2)

        let general = try #require(child("general", in: document))
        #expect(general.blocks.isEmpty)
        #expect(general.children.count == 1)
        let article = try #require(general.children.first)
        #expect(article.id == "are-esims-safe")
        #expect(article.title == "Are eSIMs safe?")
        #expect(article.children.isEmpty)
    }

    // MARK: Blocks

    @Test("Heading and paragraph blocks decode with their text")
    func headingAndParagraph() throws {
        let document = try document()
        let eligibility = try #require(child("eligibility", in: document))
        #expect(eligibility.blocks.count == 3)
        #expect(eligibility.blocks[0] == .heading("Who can sign up"))
        #expect(eligibility.blocks[1] == .paragraph("You must be able to hold an account."))

        let article = try #require(child("general", in: document)?.children.first)
        #expect(article.blocks == [.paragraph("Yes, an eSIM cannot be removed.")])
    }

    @Test("List block decodes ordered, marker and its nested items")
    func listBlock() throws {
        let document = try document()
        let eligibility = try #require(child("eligibility", in: document))
        guard case .list(let list) = eligibility.blocks[2] else {
            Issue.record("expected a list block, got \(eligibility.blocks[2])")
            return
        }
        #expect(list.ordered)
        #expect(list.marker == .decimal)
        #expect(list.items.count == 3)

        let first = try #require(list.items.first)
        #expect(first.text == "Access to benefits: eligible cardholders must:")
        #expect(first.ordered == false)
        #expect(first.marker == .bullet)
        #expect(first.items.count == 2)

        let leaf = try #require(first.items.first)
        #expect(leaf.text == "Select your region.")
        #expect(leaf.items.isEmpty)
        #expect(leaf.ordered == nil)
        #expect(leaf.marker == nil)

        #expect(list.items[1].items.isEmpty)
        #expect(list.items[1].ordered == nil)
        #expect(list.items[1].marker == nil)
    }

    // MARK: Forward compatibility

    @Test("Unknown block type decodes to .unknown")
    func unknownBlock() throws {
        let json = #"[{"type":"video","url":"x"},{"type":"paragraph","text":"p"}]"#
        let blocks: [ContentBlock] = try decode(json)
        #expect(blocks == [.unknown, .paragraph("p")])
    }

    @Test("Unknown list marker falls back to .bullet")
    func unknownMarker() throws {
        let json = #"{"type":"list","ordered":false,"marker":"roman","items":[]}"#
        let block: ContentBlock = try decode(json)
        #expect(block == .list(ContentList(ordered: false, marker: .bullet, items: [])))
    }

    // MARK: Round trip

    @Test("Encoding then decoding a document is lossless")
    func roundTrip() throws {
        let document = try document()
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
