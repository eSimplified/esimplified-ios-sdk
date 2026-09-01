//
//  OrdersPagingTests.swift
//  EsimplifiedSDK
//

import Testing
import Foundation
@testable import EsimplifiedSDK

extension NetworkSuite {

    private func makeOrdersEnv() -> (HTTPClient, SdkCache) {
        let config = SdkConfig(
            environment: .staging,
            clientName: "acme",
            clientId: "id",
            clientSecret: "secret"
        )
        let session = RecordingSessionProvider(
            initial: .authenticated(
                accessToken: "a",
                refreshToken: "r",
                expiresAt: Date().addingTimeInterval(3600)
            )
        )
        let client = HTTPClient(config: config, sessionProvider: session, session: MockSession.make())
        return (client, SdkCache())
    }

    private func ordersQuery() -> [String: String] {
        guard let url = MockURLProtocol.capturedRequests.first?.url,
              let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems else {
            return [:]
        }
        return Dictionary(items.compactMap { item in
            item.value.map { (item.name, $0) }
        }, uniquingKeysWith: { first, _ in first })
    }

    private static let emptyPage = #"{"count": 0, "next": null, "previous": null, "results": []}"#

    /// 🔴 `customer/orders/` paginates at **25** when no `limit` is sent, and none was. An account
    /// with 325 orders showed the newest 25 and silently stopped — the same shape as the eSIM list
    /// truncation.
    @Test("Orders: the unpaged read sends a limit, so it no longer stops at 25")
    func unpagedReadSendsALimit() async {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: Self.emptyPage)
        let (client, cache) = makeOrdersEnv()
        let repo = OrdersRepositoryImpl(client: client, cache: cache)

        _ = await repo.fetchOrders(withLoyaltyPoints: false)

        let query = ordersQuery()
        #expect(query["limit"] != nil)
        #expect(query["limit"] != "25")
    }

    @Test("Orders: a page asks for exactly the limit and offset it was given")
    func pageSendsLimitAndOffset() async {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: Self.emptyPage)
        let (client, cache) = makeOrdersEnv()
        let repo = OrdersRepositoryImpl(client: client, cache: cache)

        _ = await repo.fetchOrdersPageResult(
            limit: 100,
            offset: 200,
            withLoyaltyPoints: false,
            forceRefresh: false,
            cacheTTL: 600
        )

        let query = ordersQuery()
        #expect(query["limit"] == "100")
        #expect(query["offset"] == "200")
    }

    /// `next` is the only reliable "there is more" signal — comparing counts breaks if orders are
    /// added while the customer is paging.
    @Test("Orders: a next URL means hasMore, and totalCount is the whole account")
    func nextUrlMeansHasMore() async {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: """
        {
          "count": 325,
          "next": "https://api/customer/orders/?limit=25&offset=25",
          "previous": null,
          "results": []
        }
        """)
        let (client, cache) = makeOrdersEnv()
        let repo = OrdersRepositoryImpl(client: client, cache: cache)

        let page = await repo.fetchOrdersPageResult(
            limit: 25,
            offset: 0,
            withLoyaltyPoints: false,
            forceRefresh: false,
            cacheTTL: 600
        ).value

        #expect(page.hasMore)
        #expect(page.totalCount == 325)
    }

    @Test("Orders: a null next means the last page")
    func nullNextMeansLastPage() async {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: Self.emptyPage)
        let (client, cache) = makeOrdersEnv()
        let repo = OrdersRepositoryImpl(client: client, cache: cache)

        let page = await repo.fetchOrdersPageResult(
            limit: 25,
            offset: 300,
            withLoyaltyPoints: false,
            forceRefresh: false,
            cacheTTL: 600
        ).value

        #expect(!page.hasMore)
    }

    /// Without offset in the key, page 2 is served page 1's cache — every page identical.
    @Test("Orders: each page caches under its own key")
    func pagesCacheSeparately() async {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: Self.emptyPage)
        let (client, cache) = makeOrdersEnv()
        let repo = OrdersRepositoryImpl(client: client, cache: cache)

        _ = await repo.fetchOrdersPageResult(limit: 25, offset: 0, withLoyaltyPoints: false, forceRefresh: false, cacheTTL: 600)
        let firstCallCount = MockURLProtocol.capturedRequests.count

        _ = await repo.fetchOrdersPageResult(limit: 25, offset: 25, withLoyaltyPoints: false, forceRefresh: false, cacheTTL: 600)

        // The second page must reach the network rather than replay the first page's cache.
        #expect(MockURLProtocol.capturedRequests.count == firstCallCount + 1)
    }
}
