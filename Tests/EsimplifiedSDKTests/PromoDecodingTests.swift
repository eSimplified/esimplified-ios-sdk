//
//  PromoDecodingTests.swift
//  EsimplifiedSDKTests
//  Created by Kieran on 2026/09/18.
//

import Foundation
import Testing
@testable import EsimplifiedSDK

@Suite("Promo Decoding")
struct PromoDecodingTests {

    private func decode(_ json: String) throws -> MarketingPromos {
        try JSONDecoder().decode(MarketingPromos.self, from: Data(json.utf8))
    }

    @Test("A full promo decodes every field off the marketing payload")
    func decodesAFullPromo() throws {
        let response = try decode("""
        {"promos":[{
          "slug":"https://knowroaming.vercel.app/kreds",
          "title":"Got Kreds? Save on data.",
          "color":"#1E1E1E",
          "image":"https://cdn.example.com/a.webp",
          "content":"Every Kred comes off the price.",
          "cta_heading":"Your Kreds are ready to be spent.",
          "cta_text":"Check your balance",
          "faq_heading":"Buy, and earn.",
          "faqs":[{"question":"Check your balance.","answer":"Kreds from referrals."}],
          "slider_image":"https://cdn.example.com/b.webp",
          "slider_heading":"Got Kreds?",
          "slider_subheading":"Go save."
        }]}
        """)

        let promo = try #require(response.promos.first)
        #expect(promo.slug == "https://knowroaming.vercel.app/kreds")
        #expect(promo.title == "Got Kreds? Save on data.")
        #expect(promo.color == "#1E1E1E")
        #expect(promo.ctaHeading == "Your Kreds are ready to be spent.")
        #expect(promo.ctaText == "Check your balance")
        #expect(promo.faqHeading == "Buy, and earn.")
        #expect(promo.faqs.count == 1)
        #expect(promo.faqs.first?.question == "Check your balance.")
        #expect(promo.sliderHeading == "Got Kreds?")
        #expect(promo.destinationURL?.absoluteString == "https://knowroaming.vercel.app/kreds")
    }

    @Test("Null slider copy decodes rather than failing the whole payload")
    func nullSliderCopyDecodes() throws {
        let response = try decode("""
        {"promos":[{
          "slug":"https://knowroaming.vercel.app/support",
          "title":"Haven't used it. Get it all back.",
          "slider_heading":null,
          "slider_subheading":null
        }]}
        """)

        let promo = try #require(response.promos.first)
        #expect(promo.sliderHeading == nil)
        #expect(promo.sliderSubheading == nil)
        #expect(promo.faqs.isEmpty)
    }

    @Test("A promo missing every optional field still decodes")
    func missingFieldsStillDecode() throws {
        let response = try decode(#"{"promos":[{"slug":"a","title":"b"}]}"#)

        let promo = try #require(response.promos.first)
        #expect(promo.color == nil)
        #expect(promo.content == nil)
        #expect(promo.faqs.isEmpty)
    }

    @Test("A missing promos key decodes to an empty list")
    func missingPromosKeyIsEmpty() throws {
        #expect(try decode("{}").promos.isEmpty)
    }

    @Test("A bare slug is promoted to an https URL")
    func bareSlugBecomesHttps() throws {
        let response = try decode(#"{"promos":[{"slug":"knowroaming.vercel.app/kreds","title":"t"}]}"#)

        #expect(response.promos.first?.destinationURL?.scheme == "https")
    }

    @Test("An empty slug has no destination")
    func emptySlugHasNoDestination() throws {
        let response = try decode(#"{"promos":[{"slug":"","title":"t"}]}"#)

        #expect(response.promos.first?.destinationURL == nil)
    }
}
