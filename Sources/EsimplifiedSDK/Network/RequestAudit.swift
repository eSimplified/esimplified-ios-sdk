//
//  RequestAudit.swift
//  EsimplifiedSDK
//

import Foundation
import OSLog

actor RequestAudit {

    struct Entry: Sendable {
        let method: String
        let url: String
        let at: Date
    }

    private let window: TimeInterval
    private var recent: [String: Entry] = [:]
    private var duplicates: [String: Int] = [:]

    private static let signpost = Logger(subsystem: "io.esimplified.sdk", category: "request-audit")

    init(window: TimeInterval = 2.0) {
        self.window = window
    }

    static func normalise(_ url: String) -> String {
        guard let components = URLComponents(string: url) else { return url }
        guard let items = components.queryItems, !items.isEmpty else { return url }
        let sorted = items
            .map { "\($0.name)=\($0.value ?? "")" }
            .sorted()
            .joined(separator: "&")
        let base = components.scheme.map { "\($0)://" } ?? ""
        return base + (components.host ?? "") + components.path + "?" + sorted
    }

    @discardableResult
    func record(method: String, url: String, now: Date = Date()) -> Bool {
        let key = "\(method) \(Self.normalise(url))"
        defer { recent[key] = Entry(method: method, url: url, at: now) }

        guard let previous = recent[key] else { return false }
        let gap = now.timeIntervalSince(previous.at)
        guard gap >= 0, gap < window else { return false }

        duplicates[key, default: 0] += 1
        let milliseconds = String(format: "%.0f", gap * 1000)
        print("🟠 DUPLICATE REQUEST (\(milliseconds)ms apart, \(duplicates[key] ?? 0)x): \(key)")
        Self.signpost.warning("DUPLICATE \(key, privacy: .public) gap=\(milliseconds, privacy: .public)ms")
        return true
    }

    func summary() -> [(request: String, extraCalls: Int)] {
        duplicates
            .sorted { ($0.value, $0.key) > ($1.value, $1.key) }
            .map { (request: $0.key, extraCalls: $0.value) }
    }

    func reset() {
        recent.removeAll()
        duplicates.removeAll()
    }
}
