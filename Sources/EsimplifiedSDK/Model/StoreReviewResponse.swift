//
//  StoreReviewResponse.swift
//  KnowRoaming
//
//  Created by Kieran on 2025/05/21.
//

import Foundation

// MARK: Store Review Response

public struct StoreReviewResponse: Codable {
    public let reviews: [Review]?
    public let stats: Stats?
    public let storeName: String?
    public let verdict: String?
    public let reviewCount: Int?
    public let resultsCount: Int?
    public let averageRating: String?

    public init(reviews: [Review]? = nil, stats: Stats? = nil, storeName: String? = nil, verdict: String? = nil, reviewCount: Int? = nil, resultsCount: Int? = nil, averageRating: String? = nil) {
        self.reviews = reviews
        self.stats = stats
        self.storeName = storeName
        self.verdict = verdict
        self.reviewCount = reviewCount
        self.resultsCount = resultsCount
        self.averageRating = averageRating
    }

    enum CodingKeys: String, CodingKey {
        case reviews, stats, verdict
        case storeName = "store_name"
        case reviewCount = "review_count"
        case resultsCount = "results_count"
        case averageRating = "average_rating"
    }
}

// MARK: Review Model

public struct Review: Codable {
    public let type: String?
    public let typeLabel: String?
    public let rating: Int?
    public let title: String?
    public let comments: String?
    public let author: Author?
    public let dateCreated: String?
    public let timeAgo: String?
    public let sku: String?

    public init(type: String? = nil, typeLabel: String? = nil, rating: Int? = nil, title: String? = nil, comments: String? = nil, author: Author? = nil, dateCreated: String? = nil, timeAgo: String? = nil, sku: String? = nil) {
        self.type = type
        self.typeLabel = typeLabel
        self.rating = rating
        self.title = title
        self.comments = comments
        self.author = author
        self.dateCreated = dateCreated
        self.timeAgo = timeAgo
        self.sku = sku
    }

    enum CodingKeys: String, CodingKey {
        case type, rating, title, comments, author, sku
        case typeLabel = "type_label"
        case dateCreated = "date_created"
        case timeAgo = "time_ago"
    }
}

// MARK: Author Model

public struct Author: Codable {
    public let name: String?
    public let location: String?

    public init(name: String? = nil, location: String? = nil) {
        self.name = name
        self.location = location
    }
}

// MARK: Stats Model

public struct Stats: Codable {
    public let company: CompanyStats?
    public let ratings: Ratings?

    public init(company: CompanyStats? = nil, ratings: Ratings? = nil) {
        self.company = company
        self.ratings = ratings
    }
}

// MARK: Company Stats Model

public struct CompanyStats: Codable {
    public let reviewCount: Int
    public let averageRating: String

    public init(reviewCount: Int, averageRating: String) {
        self.reviewCount = reviewCount
        self.averageRating = averageRating
    }

    enum CodingKeys: String, CodingKey {
        case reviewCount = "review_count"
        case averageRating = "average_rating"
    }
}

// MARK: Ratings Model

public struct Ratings: Codable {
    public let four: Int?
    public let five: Int?

    public init(four: Int? = nil, five: Int? = nil) {
        self.four = four
        self.five = five
    }

    enum CodingKeys: String, CodingKey {
        case four = "4"
        case five = "5"
    }
}
