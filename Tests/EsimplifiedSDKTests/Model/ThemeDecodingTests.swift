//
//  ThemeDecodingTests.swift
//  EsimplifiedSDKTests
//  Created by Kieran on 2026/09/23.
//

import Foundation
import Testing
@testable import EsimplifiedSDK

@Suite("Theme Decoding")
struct ThemeDecodingTests {

    private func decode(_ json: String) throws -> ThemeResponse {
        try JSONDecoder().decode(ThemeResponse.self, from: Data(json.utf8))
    }

    private let withoutImage = """
    {
      "version": "2026-09-14T10:25:02Z",
      "cdnBase": "https://staging.cdn.esimplified.io",
      "pages": {
        "kredsinfopage": {
          "urlPath": "/kredsinfopage",
          "color": "#4D76A6"
        }
      }
    }
    """

    private let withImage = """
    {
      "version": "2026-09-14T10:25:02Z",
      "cdnBase": "https://staging.cdn.esimplified.io",
      "pages": {
        "homepage": {
          "urlPath": "/homepage",
          "featuredImage": {
            "url": "https://staging.cdn.esimplified.io/media/tenant-theming/3242ab38/pages/homepage/rebrand.webp?Expires=1792794246&Signature=abc"
          },
          "color": "#1B3244"
        }
      }
    }
    """

    @Test("A page with no featured image decodes with a colour and no image")
    func decodesAPageWithoutAnImage() throws {
        let page = try #require(decode(withoutImage).pages["kredsinfopage"])

        #expect(page.urlPath == "/kredsinfopage")
        #expect(page.color == "#4D76A6")
        #expect(page.featuredImage == nil)
    }

    @Test("A page with a featured image decodes with both")
    func decodesAPageWithAnImage() throws {
        let page = try #require(decode(withImage).pages["homepage"])

        #expect(page.urlPath == "/homepage")
        #expect(page.color == "#1B3244")
        #expect(page.featuredImage?.url.hasPrefix("https://staging.cdn.esimplified.io") == true)
        #expect(page.featuredImage?.url.contains("Signature=abc") == true)
    }

    @Test("The same page reads either way round, so adding an image server side needs no app change")
    func theSamePageSurvivesGainingAnImage() throws {
        let before = try #require(decode(withoutImage).pages["kredsinfopage"])
        let after = try #require(decode("""
        {"pages":{"kredsinfopage":{"urlPath":"/kredsinfopage","color":"#4D76A6",
        "featuredImage":{"url":"https://cdn.example.com/kreds.webp"}}}}
        """).pages["kredsinfopage"])

        #expect(before.featuredImage == nil)
        #expect(after.featuredImage?.url == "https://cdn.example.com/kreds.webp")
        #expect(before.color == after.color)
    }

    @Test("A page with neither a colour nor an image still decodes")
    func decodesAnEmptyPage() throws {
        let page = try #require(decode("""
        {"pages":{"kredsinfopage":{"urlPath":"/kredsinfopage"}}}
        """).pages["kredsinfopage"])

        #expect(page.color == nil)
        #expect(page.featuredImage == nil)
    }

    @Test("A payload with no pages key decodes to no pages")
    func decodesAPayloadWithoutPages() throws {
        let response = try decode("""
        {"version":"2026-09-14T10:25:02Z","cdnBase":"https://staging.cdn.esimplified.io"}
        """)

        #expect(response.pages.isEmpty)
        #expect(response.destinations.isEmpty)
    }

    @Test("A destination decodes its image and accent the same way")
    func decodesADestination() throws {
        let response = try decode("""
        {"destinations":{"fr":{"image":{"url":"https://cdn.example.com/fr.webp","accent":"#1A767F"}}}}
        """)
        let destination = try #require(response.destinations["fr"])

        #expect(destination.image?.url == "https://cdn.example.com/fr.webp")
        #expect(destination.image?.accent == "#1A767F")
    }
}
