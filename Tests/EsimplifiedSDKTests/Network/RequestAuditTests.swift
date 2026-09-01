//
//  RequestAuditTests.swift
//  EsimplifiedSDKTests
//

import Testing
import Foundation
@testable import EsimplifiedSDK

// MARK: - Request Audit

/// `RequestAudit` exists to catch the failure this codebase keeps repeating: the same request
/// issued more than once for a single screen. Home was making **four** `customer/esims/` calls per
/// launch, and it was found by reading console lines by hand.
///
/// Time is injected throughout so nothing here sleeps.
@Suite("Request Audit")
struct RequestAuditTests {

    private let start = Date(timeIntervalSince1970: 1_756_700_000)

    @Test("The same request twice inside the window is a duplicate")
    func duplicateInsideWindow() async {
        let audit = RequestAudit(window: 2.0)

        let first = await audit.record(method: "GET", url: "https://api/customer/esims/", now: start)
        let second = await audit.record(
            method: "GET",
            url: "https://api/customer/esims/",
            now: start.addingTimeInterval(0.2)
        )

        #expect(first == false)
        #expect(second == true)
    }

    @Test("The same request after the window is a fresh call, not a duplicate")
    func sameRequestOutsideWindow() async {
        let audit = RequestAudit(window: 2.0)

        _ = await audit.record(method: "GET", url: "https://api/customer/esims/", now: start)
        let later = await audit.record(
            method: "GET",
            url: "https://api/customer/esims/",
            now: start.addingTimeInterval(5)
        )

        #expect(later == false)
    }

    /// The point of the narrow definition: making two callers ask the SAME question is how the
    /// second one hits cache. Different query strings are different questions and must NOT be
    /// reported, or the signal drowns.
    @Test("Different query parameters are different questions, not duplicates")
    func differentQueryIsNotDuplicate() async {
        let audit = RequestAudit(window: 2.0)

        _ = await audit.record(
            method: "GET",
            url: "https://api/customer/esims/?show_legacy=false&is_primary=true",
            now: start
        )
        let other = await audit.record(
            method: "GET",
            url: "https://api/customer/esims/?show_legacy=false",
            now: start.addingTimeInterval(0.1)
        )

        #expect(other == false)
    }

    @Test("Different methods on one URL are not duplicates")
    func differentMethodIsNotDuplicate() async {
        let audit = RequestAudit(window: 2.0)

        _ = await audit.record(method: "GET", url: "https://api/customer/", now: start)
        let post = await audit.record(method: "POST", url: "https://api/customer/", now: start.addingTimeInterval(0.1))

        #expect(post == false)
    }

    @Test("A burst counts every extra call, not just the first repeat")
    func burstCountsEveryExtraCall() async {
        let audit = RequestAudit(window: 2.0)

        // Home's actual bug shape: four calls for one screen.
        for index in 0..<4 {
            _ = await audit.record(
                method: "GET",
                url: "https://api/customer/esims/",
                now: start.addingTimeInterval(Double(index) * 0.05)
            )
        }

        let summary = await audit.summary()
        #expect(summary.count == 1)
        #expect(summary.first?.extraCalls == 3)
    }

    @Test("Summary ranks the worst offender first")
    func summaryRanksWorstFirst() async {
        let audit = RequestAudit(window: 2.0)

        for index in 0..<3 {
            _ = await audit.record(method: "GET", url: "https://api/a", now: start.addingTimeInterval(Double(index) * 0.05))
        }
        for index in 0..<2 {
            _ = await audit.record(method: "GET", url: "https://api/b", now: start.addingTimeInterval(Double(index) * 0.05))
        }

        let summary = await audit.summary()
        #expect(summary.first?.request == "GET https://api/a")
        #expect(summary.first?.extraCalls == 2)
        #expect(summary.last?.extraCalls == 1)
    }

    @Test("Reset clears both the recent window and the tally")
    func resetClearsEverything() async {
        let audit = RequestAudit(window: 2.0)
        _ = await audit.record(method: "GET", url: "https://api/a", now: start)
        _ = await audit.record(method: "GET", url: "https://api/a", now: start.addingTimeInterval(0.1))

        await audit.reset()
        let afterReset = await audit.record(method: "GET", url: "https://api/a", now: start.addingTimeInterval(0.2))

        #expect(afterReset == false)
        #expect(await audit.summary().isEmpty)
    }
}
