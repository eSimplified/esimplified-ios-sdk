//
//  SdkError.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/06/04.
//

import Foundation

public enum SdkError: Error, LocalizedError {
    case networkError(statusCode: Int, message: String)
    case decodingError(Error)
    case authenticationRequired
    case noInternetConnection
    case serverError(String)
    case missingCredentials
    case invalidURL
    case unknown(Error)

    /// True when the request never reached the network. The app shows the offline sheet for
    /// these and the error sheet for everything else.
    public var isOffline: Bool {
        if case .noInternetConnection = self { return true }
        return false
    }

    public var errorDescription: String? {
        switch self {
        case .networkError(_, let message): return message
        case .decodingError(let error): return "Decoding failed: \(error.localizedDescription)"
        case .authenticationRequired: return "Authentication required"
        case .noInternetConnection: return "No internet connection"
        case .serverError(let message): return "Server error: \(message)"
        case .missingCredentials: return "Missing API credentials"
        case .invalidURL: return "Invalid URL"
        case .unknown(let error): return error.localizedDescription
        }
    }
}
