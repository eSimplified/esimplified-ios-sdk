//
//  Promo.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/09/18.
//

import Foundation

// MARK: Marketing Promos

public struct MarketingPromos: Codable, Hashable, Sendable {

    public let promos: [Promo]

    public init(promos: [Promo] = []) {
        self.promos = promos
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        promos = try container.decodeIfPresent([Promo].self, forKey: .promos) ?? []
    }
}

// MARK: Promo

public struct Promo: Codable, Hashable, Sendable, Identifiable {

    public let slug: String
    public let title: String
    public let color: String?
    public let image: String?
    public let content: String?
    public let ctaHeading: String?
    public let ctaText: String?
    public let faqHeading: String?
    public let faqs: [PromoFaq]
    public let sliderImage: String?
    public let sliderHeading: String?
    public let sliderSubheading: String?

    public var id: String { slug }

    enum CodingKeys: String, CodingKey {
        case slug
        case title
        case color
        case image
        case content
        case ctaHeading = "cta_heading"
        case ctaText = "cta_text"
        case faqHeading = "faq_heading"
        case faqs
        case sliderImage = "slider_image"
        case sliderHeading = "slider_heading"
        case sliderSubheading = "slider_subheading"
    }

    public init(
        slug: String,
        title: String,
        color: String? = nil,
        image: String? = nil,
        content: String? = nil,
        ctaHeading: String? = nil,
        ctaText: String? = nil,
        faqHeading: String? = nil,
        faqs: [PromoFaq] = [],
        sliderImage: String? = nil,
        sliderHeading: String? = nil,
        sliderSubheading: String? = nil
    ) {
        self.slug = slug
        self.title = title
        self.color = color
        self.image = image
        self.content = content
        self.ctaHeading = ctaHeading
        self.ctaText = ctaText
        self.faqHeading = faqHeading
        self.faqs = faqs
        self.sliderImage = sliderImage
        self.sliderHeading = sliderHeading
        self.sliderSubheading = sliderSubheading
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        slug = try container.decodeIfPresent(String.self, forKey: .slug) ?? ""
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        color = try container.decodeIfPresent(String.self, forKey: .color)
        image = try container.decodeIfPresent(String.self, forKey: .image)
        content = try container.decodeIfPresent(String.self, forKey: .content)
        ctaHeading = try container.decodeIfPresent(String.self, forKey: .ctaHeading)
        ctaText = try container.decodeIfPresent(String.self, forKey: .ctaText)
        faqHeading = try container.decodeIfPresent(String.self, forKey: .faqHeading)
        faqs = try container.decodeIfPresent([PromoFaq].self, forKey: .faqs) ?? []
        sliderImage = try container.decodeIfPresent(String.self, forKey: .sliderImage)
        sliderHeading = try container.decodeIfPresent(String.self, forKey: .sliderHeading)
        sliderSubheading = try container.decodeIfPresent(String.self, forKey: .sliderSubheading)
    }

    /// The promo's call to action, as a URL when the slug is one.
    public var destinationURL: URL? {
        let trimmed = slug.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        if trimmed.contains("://") { return URL(string: trimmed) }
        return URL(string: "https://\(trimmed)")
    }
}

// MARK: Promo Faq

public struct PromoFaq: Codable, Hashable, Sendable, Identifiable {

    public let question: String
    public let answer: String

    public var id: String { question }

    public init(question: String, answer: String) {
        self.question = question
        self.answer = answer
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        question = try container.decodeIfPresent(String.self, forKey: .question) ?? ""
        answer = try container.decodeIfPresent(String.self, forKey: .answer) ?? ""
    }
}
