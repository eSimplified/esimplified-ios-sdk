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
