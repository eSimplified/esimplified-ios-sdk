//
//  ApiErrorResponse.swift
//  EsimplifiedSDK
//

import Foundation

// MARK: Api Error Response

public struct ApiErrorResponse: Codable {
    public let error: String?
    public let detail: String?

    public init(error: String? = nil, detail: String? = nil) {
        self.error = error
        self.detail = detail
    }
}

// MARK: Api Invalid Response

public struct ApiInvalid: Codable {
    public let message: String?

    public init(message: String? = nil) {
        self.message = message
    }
}
