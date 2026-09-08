//
//  DestinationFaqResponse.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/09/01.
//

import Foundation

// MARK: Destination FAQ Response

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

public struct Faq: Codable, Hashable {

    public let question: String
    public let answer: String

    public init(question: String, answer: String) {
        self.question = question
        self.answer = answer
    }
}
