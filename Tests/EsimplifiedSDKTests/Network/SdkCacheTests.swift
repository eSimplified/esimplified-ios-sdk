//
//  SdkCacheTests.swift
//  EsimplifiedSDK
//

import Testing
import Foundation
@testable import EsimplifiedSDK

@Suite("SdkCache")
struct SdkCacheTests {

    @Test("Returns cached value within TTL")
    func cacheHit() async {
        let cache = SdkCache(defaultTTL: 60)
        await cache.set("key", value: [1, 2, 3])
        let value: [Int]? = await cache.get("key")
        #expect(value == [1, 2, 3])
    }

    @Test("Returns nil when TTL expires")
    func cacheMissAfterExpiry() async {
        let cache = SdkCache(defaultTTL: 0.05)
        await cache.set("key", value: "old")
        try? await Task.sleep(nanoseconds: 100_000_000)
        let value: String? = await cache.get("key")
        #expect(value == nil)
    }

    @Test("getExpired returns expired value as fallback")
    func getExpiredReturnsStaleValue() async {
        let cache = SdkCache(defaultTTL: 0.05)
        await cache.set("key", value: "stale")
        try? await Task.sleep(nanoseconds: 100_000_000)

        let fresh: String? = await cache.get("key")
        #expect(fresh == nil)

        let expired: String? = await cache.getExpired("key")
        #expect(expired == "stale")
    }

    @Test("Per-set TTL overrides default TTL")
    func perSetTTLOverride() async {
        let cache = SdkCache(defaultTTL: 0.05)
        await cache.set("default-key", value: "x")
        await cache.set("long-key", value: "y", ttl: 60)

        try? await Task.sleep(nanoseconds: 100_000_000)

        let defaultValue: String? = await cache.get("default-key")
        let longValue: String? = await cache.get("long-key")
        #expect(defaultValue == nil)
        #expect(longValue == "y")
    }

    @Test("remove deletes a single key")
    func removeSingleKey() async {
        let cache = SdkCache()
        await cache.set("a", value: "1")
        await cache.set("b", value: "2")
        await cache.remove("a")

        let a: String? = await cache.get("a")
        let b: String? = await cache.get("b")
        #expect(a == nil)
        #expect(b == "2")
    }

    @Test("removeWithPrefix deletes matching keys only")
    func removeByPrefix() async {
        let cache = SdkCache()
        await cache.set("countries_all", value: "x")
        await cache.set("countries_top", value: "y")
        await cache.set("orders_list", value: "z")

        await cache.removeWithPrefix("countries_")

        let a: String? = await cache.get("countries_all")
        let b: String? = await cache.get("countries_top")
        let c: String? = await cache.get("orders_list")
        #expect(a == nil)
        #expect(b == nil)
        #expect(c == "z")
    }

    @Test("clear deletes all keys")
    func clearAll() async {
        let cache = SdkCache()
        await cache.set("a", value: "1")
        await cache.set("b", value: "2")
        await cache.clear()

        let a: String? = await cache.get("a")
        let b: String? = await cache.get("b")
        #expect(a == nil)
        #expect(b == nil)
    }

    @Test("Cache stores heterogeneous types via generics")
    func cacheStoresVariousTypes() async {
        let cache = SdkCache()
        await cache.set("int", value: 42)
        await cache.set("string", value: "hello")
        await cache.set("array", value: [1, 2, 3])
        struct Item: Equatable { let name: String }
        await cache.set("struct", value: Item(name: "a"))

        let i: Int? = await cache.get("int")
        let s: String? = await cache.get("string")
        let a: [Int]? = await cache.get("array")
        let st: Item? = await cache.get("struct")
        #expect(i == 42)
        #expect(s == "hello")
        #expect(a == [1, 2, 3])
        #expect(st == Item(name: "a"))
    }

    @Test("Type mismatch on get returns nil")
    func typeMismatchYieldsNil() async {
        let cache = SdkCache()
        await cache.set("key", value: 42)
        let wrong: String? = await cache.get("key")
        #expect(wrong == nil)
    }

    @Test("Overwriting a key updates value and resets TTL")
    func overwriteResetsTTL() async {
        let cache = SdkCache(defaultTTL: 0.05)
        await cache.set("key", value: "old")
        try? await Task.sleep(nanoseconds: 30_000_000)
        await cache.set("key", value: "new", ttl: 60)

        try? await Task.sleep(nanoseconds: 100_000_000)
        let value: String? = await cache.get("key")
        #expect(value == "new")
    }
}

@Suite("EsimplifiedSdk clearAllCaches")
struct ClearAllCachesTests {

    @Test("clearAllCaches does not crash and remains callable")
    func clearAllCachesCallable() async {
        let sdk = EsimplifiedSdk.initialize(
            config: SdkConfig(environment: .staging, clientName: "t", clientId: "i", clientSecret: "s")
        )
        await sdk.clearAllCaches()
    }
}
