//
//  MockURLProtocol.swift
//  EsimplifiedSDK
//

import Foundation
import Testing
@testable import EsimplifiedSDK

/// One shared serialized suite for every test that touches `MockURLProtocol`.
/// Swift Testing's `.serialized` trait only serializes WITHIN a suite, so all
/// MockURLProtocol-using tests must extend this single type.
@Suite("Network", .serialized)
struct NetworkSuite {}

final class MockURLProtocol: URLProtocol {

    typealias Handler = (URLRequest) throws -> (HTTPURLResponse, Data?)

    private static let lock = NSLock()
    private static var currentHandler: Handler?
    private static var requestLog: [URLRequest] = []
    private static var bodyLog: [Data?] = []

    static var handler: Handler? {
        get { lock.lock(); defer { lock.unlock() }; return currentHandler }
        set { lock.lock(); defer { lock.unlock() }; currentHandler = newValue }
    }

    static var capturedRequests: [URLRequest] {
        lock.lock(); defer { lock.unlock() }
        return requestLog
    }

    static var capturedBodies: [Data?] {
        lock.lock(); defer { lock.unlock() }
        return bodyLog
    }

    static func reset() {
        lock.lock(); defer { lock.unlock() }
        currentHandler = nil
        requestLog = []
        bodyLog = []
    }

    private static func readBody(from request: URLRequest) -> Data? {
        if let body = request.httpBody { return body }
        guard let stream = request.httpBodyStream else { return nil }
        stream.open()
        defer { stream.close() }
        var data = Data()
        let bufferSize = 1024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer { buffer.deallocate() }
        while stream.hasBytesAvailable {
            let read = stream.read(buffer, maxLength: bufferSize)
            if read <= 0 { break }
            data.append(buffer, count: read)
        }
        return data
    }

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        let capturedBody = MockURLProtocol.readBody(from: request)
        MockURLProtocol.lock.lock()
        MockURLProtocol.requestLog.append(request)
        MockURLProtocol.bodyLog.append(capturedBody)
        let handler = MockURLProtocol.currentHandler
        MockURLProtocol.lock.unlock()

        guard let handler else {
            client?.urlProtocol(self, didFailWithError: URLError(.unsupportedURL))
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            if let data {
                client?.urlProtocol(self, didLoad: data)
            }
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

enum MockSession {
    static func make() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: config)
    }

    static func jsonResponse(statusCode: Int = 200, json: String) -> MockURLProtocol.Handler {
        return { request in
            guard let url = request.url else { throw URLError(.badURL) }
            let response = HTTPURLResponse(
                url: url,
                statusCode: statusCode,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, json.data(using: .utf8))
        }
    }

    static func emptyResponse(statusCode: Int) -> MockURLProtocol.Handler {
        return { request in
            guard let url = request.url else { throw URLError(.badURL) }
            let response = HTTPURLResponse(
                url: url,
                statusCode: statusCode,
                httpVersion: "HTTP/1.1",
                headerFields: nil
            )!
            return (response, nil)
        }
    }

    /// Returns responses in sequence based on call count. Useful for testing 401-then-success flows.
    static func sequence(_ steps: [(statusCode: Int, json: String?)]) -> MockURLProtocol.Handler {
        let counter = AtomicCounter()
        return { request in
            guard let url = request.url else { throw URLError(.badURL) }
            let index = counter.incrementAndGet() - 1
            let step = steps[min(index, steps.count - 1)]
            let response = HTTPURLResponse(
                url: url,
                statusCode: step.statusCode,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, step.json?.data(using: .utf8))
        }
    }
}

final class AtomicCounter: @unchecked Sendable {
    private let lock = NSLock()
    private var value = 0
    func incrementAndGet() -> Int {
        lock.lock(); defer { lock.unlock() }
        value += 1
        return value
    }
    func current() -> Int {
        lock.lock(); defer { lock.unlock() }
        return value
    }
}

final class RecordingSessionProvider: SessionProvider, @unchecked Sendable {
    private let lock = NSLock()
    private var state: AuthState
    private(set) var tokenRefreshedCalls: [SignInCustomerResponse] = []
    private(set) var authenticationFailedCalls = 0
    private(set) var saveAuthStateCalls: [AuthState] = []
    private(set) var clearSessionCalls = 0

    init(initial: AuthState = .unauthenticated) {
        self.state = initial
    }

    func saveAuthState(_ state: AuthState) throws {
        lock.lock(); defer { lock.unlock() }
        saveAuthStateCalls.append(state)
        self.state = state
    }

    func getAuthState() -> AuthState {
        lock.lock(); defer { lock.unlock() }
        return state
    }

    func getAccessToken() -> String? {
        lock.lock(); defer { lock.unlock() }
        return state.accessToken
    }

    func getRefreshToken() -> String? {
        lock.lock(); defer { lock.unlock() }
        return state.refreshToken
    }

    func clearSession() throws {
        lock.lock(); defer { lock.unlock() }
        clearSessionCalls += 1
        state = .unauthenticated
    }

    func onTokenRefreshed(response: SignInCustomerResponse) {
        lock.lock(); defer { lock.unlock() }
        tokenRefreshedCalls.append(response)
    }

    func onAuthenticationFailed() {
        lock.lock(); defer { lock.unlock() }
        authenticationFailedCalls += 1
    }
}
