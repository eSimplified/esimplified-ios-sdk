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
}

// MARK: Api Invalid Response

public struct ApiInvalid: Codable {
    public let message: String?
}
