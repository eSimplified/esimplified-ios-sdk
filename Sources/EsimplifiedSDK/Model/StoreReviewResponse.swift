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
}

// MARK: Stats Model

public struct Stats: Codable {
    public let company: CompanyStats?
    public let ratings: Ratings?
}

// MARK: Company Stats Model

public struct CompanyStats: Codable {
    public let reviewCount: Int
    public let averageRating: String

    enum CodingKeys: String, CodingKey {
        case reviewCount = "review_count"
        case averageRating = "average_rating"
    }
}

// MARK: Ratings Model

public struct Ratings: Codable {
    public let four: Int?
    public let five: Int?

    enum CodingKeys: String, CodingKey {
        case four = "4"
        case five = "5"
    }
}
