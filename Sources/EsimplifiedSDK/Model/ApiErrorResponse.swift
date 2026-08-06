//
//  ApiErrorResponse.swift
//  KnowRoaming
//
//  Created by Kieran on 2025/03/18.
//

import Foundation

// MARK: Api Error Response

public struct ApiErrorResponse: Codable {
    public let error: String?
    public let detail: String?
    /// Localized, user-facing message — e.g. payment validation errors send a generic
    /// `detail` ("Payment request failed") with the real localized text in `message`.
    public let message: String?
    public let type: String?

    public init(error: String? = nil, detail: String? = nil, message: String? = nil, type: String? = nil) {
        self.error = error
        self.detail = detail
        self.message = message
        self.type = type
    }
}

// MARK: Server Error Response (OAuth2 auth endpoint)

public struct ServerErrorResponse: Codable {
    public let error: String?
    public let errorDescription: String?

    enum CodingKeys: String, CodingKey {
        case error
        case errorDescription = "error_description"
    }

    public init(error: String? = nil, errorDescription: String? = nil) {
        self.error = error
        self.errorDescription = errorDescription
    }
}

// MARK: Api Invalid Response

public struct ApiInvalid: Codable {
    public let message: String?

    public init(message: String? = nil) {
        self.message = message
    }
}
