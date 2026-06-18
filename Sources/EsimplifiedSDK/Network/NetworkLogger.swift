//
//  NetworkLogger.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/06/04.
//

import Foundation

struct NetworkLogger {

    let isEnabled: Bool

    func logRequest(method: String, url: String, headers: [String: String]?, body: Data?) {
        guard isEnabled else { return }
        print("🔵 REQUEST: \(method) - URL: \(url)")
        if let headers {
            for (key, value) in headers.sorted(by: { $0.key < $1.key }) {
                print("   📋 \(key): \(Self.redactHeaderValue(name: key, value: value))")
            }
        }
        if let body, let bodyString = String(data: body, encoding: .utf8) {
            let contentType = headers?.first(where: { $0.key.lowercased() == "content-type" })?.value ?? ""
            print("   📦 Body: \(Self.redactBody(raw: bodyString, contentType: contentType))")
        }
    }

    func logResponse(method: String, url: String, statusCode: Int, duration: TimeInterval, body: Data?) {
        guard isEnabled else { return }
        let emoji = (200...299).contains(statusCode) ? "✅" : "⚠️"
        print("\(emoji) RESPONSE: \(url) - Status: \(statusCode) (\(String(format: "%.0f", duration * 1000))ms)")
        if let body, let bodyString = String(data: body, encoding: .utf8) {
            let redacted = Self.redactBody(raw: bodyString, contentType: "application/json")
            let truncated = redacted.count > 1024 ? String(redacted.prefix(1024)) + "... (truncated)" : redacted
            print("Response data: \(truncated)")
        }
    }

    func logError(method: String, url: String, error: Error) {
        guard isEnabled else { return }
        print("🔴 NETWORK ERROR: \(url) - \(error)")
    }

    // MARK: Redaction

    private static let sensitiveHeaders: Set<String> = [
        "authorization",
        "x-auth-validation",
        "x-firebase-appcheck",
        "cookie",
        "set-cookie",
    ]

    private static let sensitiveBodyKeys: Set<String> = [
        "password",
        "current_password",
        "new_password",
        "old_password",
        "client_secret",
        "secret",
        "refresh_token",
        "access_token",
        "token",
        "ephemeral_key",
        "publishable_key",
        "activation_code",
        "qr_code",
        "sm_dp_address",
        "customer_ref",
    ]

    private static let redactedPlaceholder = "***REDACTED***"

    static func redactHeaderValue(name: String, value: String) -> String {
        sensitiveHeaders.contains(name.lowercased()) ? redactedPlaceholder : value
    }

    static func redactBody(raw: String, contentType: String) -> String {
        guard !raw.isEmpty else { return raw }
        if contentType.range(of: "json", options: .caseInsensitive) != nil {
            return redactJSON(raw)
        }
        if contentType.range(of: "x-www-form-urlencoded", options: .caseInsensitive) != nil {
            return redactForm(raw)
        }
        return raw
    }

    private static func redactJSON(_ raw: String) -> String {
        guard let data = raw.data(using: .utf8),
              let parsed = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) else {
            return raw
        }
        let redacted = redactValue(parsed)
        guard let outputData = try? JSONSerialization.data(withJSONObject: redacted, options: .prettyPrinted),
              let outputString = String(data: outputData, encoding: .utf8) else {
            return raw
        }
        return outputString
    }

    private static func redactValue(_ value: Any) -> Any {
        if let dictionary = value as? [String: Any] {
            var output: [String: Any] = [:]
            for (key, nested) in dictionary {
                if sensitiveBodyKeys.contains(key.lowercased()), !(nested is NSNull) {
                    output[key] = redactedPlaceholder
                } else {
                    output[key] = redactValue(nested)
                }
            }
            return output
        }
        if let array = value as? [Any] {
            return array.map { redactValue($0) }
        }
        return value
    }

    private static func redactForm(_ raw: String) -> String {
        let pairs = raw.split(separator: "&").map { pair -> String in
            let parts = pair.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
            guard parts.count == 2 else { return String(pair) }
            let key = String(parts[0])
            let value = String(parts[1])
            if sensitiveBodyKeys.contains(key.lowercased()) {
                return "\(key)=\(redactedPlaceholder)"
            }
            return "\(key)=\(value)"
        }
        return pairs.joined(separator: "&")
    }
}
