//
//  SupportLabels.swift
//  EsimplifiedSDK
//  Created by Zivaiishe Kanengoni on 2026/09/09.
//

import Foundation

// MARK: Support Labels
public struct SupportLabels: Codable, Hashable, Sendable {

    public let article: Article?
    public let categories: Categories?
    public let popular: Popular?
    public let search: Search?
    public let cta: Cta?
    public let hero: Hero?

    public init(
        article: Article? = nil,
        categories: Categories? = nil,
        popular: Popular? = nil,
        search: Search? = nil,
        cta: Cta? = nil,
        hero: Hero? = nil
    ) {
        self.article = article
        self.categories = categories
        self.popular = popular
        self.search = search
        self.cta = cta
        self.hero = hero
    }

    // MARK: Article

    public struct Article: Codable, Hashable, Sendable {

        public let contactTitle: String?
        public let contactDescription: String?
        public let contactAction: String?
        public let relatedTitle: String?
        public let breadcrumbRoot: String?

        public init(
            contactTitle: String? = nil,
            contactDescription: String? = nil,
            contactAction: String? = nil,
            relatedTitle: String? = nil,
            breadcrumbRoot: String? = nil
        ) {
            self.contactTitle = contactTitle
            self.contactDescription = contactDescription
            self.contactAction = contactAction
            self.relatedTitle = relatedTitle
            self.breadcrumbRoot = breadcrumbRoot
        }
    }

    // MARK: Categories

    public struct Categories: Codable, Hashable, Sendable {

        public let articleCount: String?
        public let lead: String?
        public let titleLead: String?
        public let titleRest: String?
        public let listLabel: String?

        public init(
            articleCount: String? = nil,
            lead: String? = nil,
            titleLead: String? = nil,
            titleRest: String? = nil,
            listLabel: String? = nil
        ) {
            self.articleCount = articleCount
            self.lead = lead
            self.titleLead = titleLead
            self.titleRest = titleRest
            self.listLabel = listLabel
        }
    }

    // MARK: Popular

    public struct Popular: Codable, Hashable, Sendable {

        public let lead: String?
        public let titleLead: String?
        public let titleRest: String?
        public let readTime: String?
        public let listLabel: String?

        public init(
            lead: String? = nil,
            titleLead: String? = nil,
            titleRest: String? = nil,
            readTime: String? = nil,
            listLabel: String? = nil
        ) {
            self.lead = lead
            self.titleLead = titleLead
            self.titleRest = titleRest
            self.readTime = readTime
            self.listLabel = listLabel
        }
    }

    // MARK: Search

    public struct Search: Codable, Hashable, Sendable {

        public let empty: String?
        public let countOne: String?
        public let countOther: String?
        public let clear: String?
        public let resultsLabel: String?

        public init(
            empty: String? = nil,
            countOne: String? = nil,
            countOther: String? = nil,
            clear: String? = nil,
            resultsLabel: String? = nil
        ) {
            self.empty = empty
            self.countOne = countOne
            self.countOther = countOther
            self.clear = clear
            self.resultsLabel = resultsLabel
        }
    }

    // MARK: Cta

    public struct Cta: Codable, Hashable, Sendable {

        public let whatsapp: String?
        public let email: String?
        public let lead: String?
        public let titleLead: String?
        public let titleRest: String?
        public let description: String?

        public init(
            whatsapp: String? = nil,
            email: String? = nil,
            lead: String? = nil,
            titleLead: String? = nil,
            titleRest: String? = nil,
            description: String? = nil
        ) {
            self.whatsapp = whatsapp
            self.email = email
            self.lead = lead
            self.titleLead = titleLead
            self.titleRest = titleRest
            self.description = description
        }
    }

    // MARK: Hero

    public struct Hero: Codable, Hashable, Sendable {

        public let searchPlaceholder: String?
        public let searchLabel: String?
        public let try1: String?
        public let try2: String?
        public let try3: String?
        public let try4: String?
        public let tryLabel: String?

        public init(
            searchPlaceholder: String? = nil,
            searchLabel: String? = nil,
            try1: String? = nil,
            try2: String? = nil,
            try3: String? = nil,
            try4: String? = nil,
            tryLabel: String? = nil
        ) {
            self.searchPlaceholder = searchPlaceholder
            self.searchLabel = searchLabel
            self.try1 = try1
            self.try2 = try2
            self.try3 = try3
            self.try4 = try4
            self.tryLabel = tryLabel
        }
    }
}
