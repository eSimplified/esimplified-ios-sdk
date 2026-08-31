//
//  RepositoryResult.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/08/31.
//

import Foundation

/// A cache-first read that also says why the refresh failed.
///
/// The reads deliberately do NOT throw: throwing would discard the cached value the app still
/// wants to render. Without `failure`, a dead request and a genuinely empty result are the same
/// value, so a caller cannot tell "no plans for this country" from "the request never landed".
public struct RepositoryResult<Value> {

    /// Cache-first, exactly as the non-`Result` signatures have always behaved.
    public let value: Value

    /// The value came from an entry that had already expired.
    public let isStale: Bool

    /// Why the refresh failed. `nil` when the value is fresh from the network or a valid cache.
    public let failure: SdkError?

    public init(value: Value, isStale: Bool = false, failure: SdkError? = nil) {
        self.value = value
        self.isStale = isStale
        self.failure = failure
    }

    public var didFail: Bool { failure != nil }

    /// The request never reached the network, so the app shows the offline sheet rather than
    /// the error sheet.
    public var isOffline: Bool { failure?.isOffline == true }
}
