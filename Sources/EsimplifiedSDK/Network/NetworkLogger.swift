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
                let safeValue = key.lowercased() == "authorization" ? "\(value.prefix(20))..." : value
                print("   📋 \(key): \(safeValue)")
            }
        }
        if let body, let bodyString = String(data: body, encoding: .utf8) {
            print("   📦 Body: \(bodyString)")
        }
    }

    func logResponse(method: String, url: String, statusCode: Int, duration: TimeInterval, body: Data?) {
        guard isEnabled else { return }
        let emoji = (200...299).contains(statusCode) ? "✅" : "⚠️"
        print("\(emoji) RESPONSE: \(url) - Status: \(statusCode) (\(String(format: "%.0f", duration * 1000))ms)")
        if let body {
            if let json = try? JSONSerialization.jsonObject(with: body, options: []),
               let prettyData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
               let prettyString = String(data: prettyData, encoding: .utf8) {
                let truncated = prettyString.count > 1024 ? String(prettyString.prefix(1024)) + "... (truncated)" : prettyString
                print("Response data: \(truncated)")
            } else if let bodyString = String(data: body, encoding: .utf8) {
                let truncated = bodyString.count > 1024 ? String(bodyString.prefix(1024)) + "... (truncated)" : bodyString
                print("Response data: \(truncated)")
            }
        }
    }

    func logError(method: String, url: String, error: Error) {
        guard isEnabled else { return }
        print("🔴 NETWORK ERROR: \(url) - \(error)")
    }
}
