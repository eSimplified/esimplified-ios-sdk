//
//  RequestAudit.swift
//  EsimplifiedSDK
//

import Foundation
import OSLog

/// Flags the same request being issued twice in quick succession.
///
/// Duplicate fetches are the failure mode this codebase keeps hitting, and they are invisible in a
/// normal log: the lines look correct, there are simply more of them than anyone counts. Home was
/// found issuing **four** `customer/esims/` calls per launch only because someone read the console
/// line by line. This does that counting automatically.
///
/// A duplicate here means *the same method and URL within `window` seconds*. That is deliberately
/// narrow — two different query strings are two different questions, and one of the fixes this
/// year was precisely to make two callers ask the SAME question so the second hits cache.
///
/// **Debug tooling.** Every entry point is `#if DEBUG`, so this type has no release footprint. It
/// reports; it never changes behaviour, and it never coalesces or suppresses a request.
actor RequestAudit {

    struct Entry: Sendable {
        let method: String
        let url: String
        let at: Date
    }

    /// Two calls closer together than this are treated as one duplicate. Sized for a screen
    /// appearing: independent taps are seconds apart, a redundant fetch is milliseconds.
    private let window: TimeInterval
    private var recent: [String: Entry] = [:]
    private var duplicates: [String: Int] = [:]

    private static let signpost = Logger(subsystem: "io.esimplified.sdk", category: "request-audit")

    init(window: TimeInterval = 2.0) {
        self.window = window
    }

    /// Records a request and reports whether it duplicates a very recent one.
    ///
    /// `now` is injected so tests do not sleep.
    @discardableResult
    func record(method: String, url: String, now: Date = Date()) -> Bool {
        let key = "\(method) \(url)"
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

    /// Every duplicated request seen so far, most-duplicated first. For a test, or for reading at
    /// the end of a manual flow.
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
