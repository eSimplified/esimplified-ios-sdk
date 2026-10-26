import Testing
import Foundation
@testable import EsimplifiedSDK

private final class ScriptedOrders: OrdersRepositoryType {
    var results: [Result<OrderDetail, Error>]
    var calls = 0
    init(_ results: [Result<OrderDetail, Error>]) { self.results = results }
    func fetchOrder(orderUUID: String, forceRefresh: Bool, cacheTTL: TimeInterval) async throws -> OrderDetail {
        calls += 1
        return try results.removeFirst().get()
    }
    func fetchOrders(forceRefresh: Bool, withLoyaltyPoints: Bool, cacheTTL: TimeInterval) async -> [Order] { [] }
    func trackedOrder(orderUUID: String) async {}
    func invalidateCache() async {}
}

private func order(_ orderStatus: String, _ paymentStatus: String?, iccid: String? = "8901234567890123456") -> OrderDetail {
    try! JSONDecoder().decode(
        OrderDetail.self,
        from: Data(OrderDetailJSON.make(orderStatus: orderStatus, paymentStatus: paymentStatus, iccid: iccid).utf8)
    )
}

@Suite("OrderSettlement")
struct OrderSettlementTests {

    private func settle(_ repo: ScriptedOrders, timeout: Duration = .seconds(120)) async -> OrderSettlement {
        await repo.awaitSettlement(orderUUID: "order-1", interval: .seconds(3), timeout: timeout, sleep: { _ in })
    }

    @Test("fulfilledOnThirdPoll")
    func fulfilledOnThirdPoll() async {
        let repo = ScriptedOrders([
            .success(order("pending", "pending", iccid: nil)),
            .success(order("pending", "pending", iccid: nil)),
            .success(order("success", "success"))
        ])
        let result = await settle(repo)
        guard case .fulfilled = result else {
            Issue.record("expected fulfilled, got \(result)")
            return
        }
        #expect(repo.calls == 3)
    }

    @Test("failedStopsPolling")
    func failedStopsPolling() async {
        let repo = ScriptedOrders([.success(order("pending", "failed", iccid: nil))])
        let result = await settle(repo)
        guard case .failed = result else {
            Issue.record("expected failed, got \(result)")
            return
        }
        #expect(repo.calls == 1)
    }

    @Test("cancelledIsFailure")
    func cancelledIsFailure() async {
        let repo = ScriptedOrders([.success(order("cancelled", nil, iccid: nil))])
        let result = await settle(repo)
        guard case .failed = result else {
            Issue.record("expected failed, got \(result)")
            return
        }
    }

    @Test("iccidWithPendingPaymentKeepsPolling")
    func iccidWithPendingPaymentKeepsPolling() async {
        let repo = ScriptedOrders([
            .success(order("success", "pending")),
            .success(order("success", "success"))
        ])
        let result = await settle(repo)
        guard case .fulfilled = result else {
            Issue.record("expected fulfilled, got \(result)")
            return
        }
        #expect(repo.calls == 2)
    }

    @Test("missingPaymentStatusFallsBackToOrderStatus")
    func missingPaymentStatusFallsBackToOrderStatus() async {
        let repo = ScriptedOrders([.success(order("success", nil))])
        let result = await settle(repo)
        guard case .fulfilled = result else {
            Issue.record("expected fulfilled, got \(result)")
            return
        }
    }

    @Test("fetchErrorThenSuccess")
    func fetchErrorThenSuccess() async {
        let repo = ScriptedOrders([
            .failure(SdkError.noInternetConnection),
            .success(order("success", "success"))
        ])
        let result = await settle(repo)
        guard case .fulfilled = result else {
            Issue.record("expected fulfilled, got \(result)")
            return
        }
        #expect(repo.calls == 2)
    }

    @Test("timesOutPending")
    func timesOutPending() async {
        let pending = order("pending", "pending", iccid: nil)
        let repo = ScriptedOrders([.success(pending), .success(pending), .success(pending)])
        let result = await settle(repo, timeout: .zero)
        guard case .pending(let last) = result else {
            Issue.record("expected pending, got \(result)")
            return
        }
        #expect(last != nil)
        #expect(last?.orderStatus == "pending")
        #expect(repo.calls == 1)
    }
}
