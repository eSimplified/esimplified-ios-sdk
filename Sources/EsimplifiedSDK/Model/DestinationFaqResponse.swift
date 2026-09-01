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

/// Deliberately NOT `Identifiable`. The service sends no id, and it does not need to: the response
/// is an ORDERED array, so a row's position is its identity — the first entry is the first card.
/// Callers key their `ForEach` on the index, which cannot collide the way a question string can.
public struct Faq: Codable, Hashable {

    public let question: String
    public let answer: String

    public init(question: String, answer: String) {
        self.question = question
        self.answer = answer
    }
}
