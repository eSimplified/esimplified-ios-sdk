//
//  DestinationFaqResponse.swift
//  EsimplifiedSDK
//

import Foundation

// MARK: Destination FAQ Response

/// 🔴 NOT the paginated `{count, next, previous, results}` envelope every other list endpoint uses.
/// `faqs/destinations/{slug}` returns the destination itself with the questions nested inside, so a
/// generic list decoder does not fit here.
///
/// `language` echoes what the service resolved from `accept-language`, which the app already sends
/// for every request via `customHeadersProvider`.
public struct DestinationFaqResponse: Codable, Hashable {

    public let slug: String
    public let name: String
    public let language: String
    public let faqs: [Faq]

    public init(slug: String, name: String, language: String, faqs: [Faq]) {
        self.slug = slug
        self.name = name
        self.language = language
        self.faqs = faqs
    }
}

// MARK: FAQ

public struct Faq: Codable, Hashable, Identifiable {

    public let question: String
    public let answer: String

    /// The question, because the service sends no id. Two identical questions on one destination
    /// would collide in a `ForEach`, but that is a content error worth seeing rather than hiding
    /// behind a synthesised `UUID` that changes on every decode and breaks view identity.
    public var id: String { question }

    public init(question: String, answer: String) {
        self.question = question
        self.answer = answer
    }
}
