//
//  SdkError.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/06/04.
//

import Foundation

public enum SdkError: Error, LocalizedError, CustomDebugStringConvertible {
    case networkError(statusCode: Int, message: String, code: String? = nil)
    case decodingError(Error)
    case authenticationRequired
    case noInternetConnection
    case serverError(String)
    case missingCredentials
    case invalidURL
    case unknown(Error)

    public var isOffline: Bool {
        if case .noInternetConnection = self { return true }
        return false
    }

    /// The HTTP status of a `networkError`, nil for every other case.
    public var statusCode: Int? {
        if case .networkError(let statusCode, _, _) = self { return statusCode }
        return nil
    }

    /// The machine-readable `code` the API put in the error body, e.g. `invalid_code`.
    public var apiCode: String? {
        if case .networkError(_, _, let code) = self { return code }
        return nil
    }

    public func hasApiCode(_ code: ApiErrorCode) -> Bool {
        apiCode == code.rawValue
    }

    public var debugDescription: String {
        switch self {
        case .decodingError(let error): return "Decoding failed: \(Self.describe(error))"
        case .serverError(let message): return "Server error: \(message)"
        default: return errorDescription ?? "\(self)"
        }
    }

    private static func describe(_ error: Error) -> String {
        guard let decodingError = error as? DecodingError else { return error.localizedDescription }
        switch decodingError {
        case .keyNotFound(let key, let context):
            return "missing key '\(key.stringValue)'\(path(context))"
        case .valueNotFound(let type, let context):
            return "null value for \(type)\(path(context))"
        case .typeMismatch(let type, let context):
            return "expected \(type)\(path(context))"
        case .dataCorrupted(let context):
            return "corrupted data\(path(context)) — \(context.debugDescription)"
        @unknown default:
            return decodingError.localizedDescription
        }
    }

    private static func path(_ context: DecodingError.Context) -> String {
        let keys = context.codingPath.map(\.stringValue)
        return keys.isEmpty ? "" : " at \(keys.joined(separator: "."))"
    }

    public var errorDescription: String? {
        switch self {
        case .networkError(_, let message, _): return message
        case .decodingError: return "Something went wrong. Please try again."
        case .authenticationRequired: return "Authentication required"
        case .noInternetConnection: return "No internet connection"
        case .serverError(let message): return message
        case .missingCredentials: return "Missing API credentials"
        case .invalidURL: return "Invalid URL"
        case .unknown(let error): return error.localizedDescription
        }
    }
}

// MARK: Api Error Code

/// Error codes the API sends in the body's `code` field.
public enum ApiErrorCode: String {
    case invalidCode = "invalid_code"
    case codeExpired = "code_expired"
    case phoneAlreadyVerified = "phone_already_verified"
    case noPendingVerification = "no_pending_verification"
    case tooManyRequests = "too_many_requests"
    case providerError = "provider_error"
    case phoneVerificationRequired = "phone_verification_required"
}
