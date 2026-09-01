//
//  RepositoryResult.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/08/31.
//

import Foundation

public struct RepositoryResult<Value> {

    public let value: Value

    public let isStale: Bool

    public let failure: SdkError?

    public init(value: Value, isStale: Bool = false, failure: SdkError? = nil) {
        self.value = value
        self.isStale = isStale
        self.failure = failure
    }

    public var didFail: Bool { failure != nil }

    public var isOffline: Bool { failure?.isOffline == true }
}
