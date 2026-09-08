//
//  ApiErrorMessage.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/09/07.
//

import Foundation

// MARK: Api Error Message

enum ApiErrorMessage {

    static let fallback = "Unknown error"

    private static let unlabelledKeys: Set<String> = ["non_field_errors", "errors", "error", "detail", "message"]

    static func parse(_ data: Data) -> String {
        if let apiError = try? JSONDecoder().decode(ApiErrorResponse.self, from: data),
           let message = apiError.message ?? apiError.detail ?? apiError.error {
            return message
        }
        if let object = try? JSONSerialization.jsonObject(with: data) {
            let messages = flatten(object, key: nil)
            return messages.isEmpty ? fallback : messages.joined(separator: "\n")
        }
        if let text = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
           !text.isEmpty {
            return text
        }
        return fallback
    }

    private static func flatten(_ value: Any, key: String?) -> [String] {
        switch value {
        case let string as String:
            guard let key, !unlabelledKeys.contains(key) else { return [string] }
            return ["\(humanize(key)): \(string)"]
        case let array as [Any]:
            return array.flatMap { flatten($0, key: key) }
        case let dictionary as [String: Any]:
            return dictionary
                .sorted { $0.key < $1.key }
                .flatMap { flatten($0.value, key: $0.key) }
        default:
            return []
        }
    }

    private static func humanize(_ key: String) -> String {
        let words = key.replacingOccurrences(of: "_", with: " ")
        return words.prefix(1).uppercased() + words.dropFirst()
    }
}
