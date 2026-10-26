import Testing
import Foundation
@testable import EsimplifiedSDK

extension NetworkSuite {

    @Suite("OrdersRepositoryImpl settlement")
    struct OrdersRepositoryImplSettlementTests {

        private func makeRepo() -> OrdersRepositoryImpl {
            let config = SdkConfig(
                environment: .staging,
                clientName: "acme",
                clientId: "id",
                clientSecret: "secret"
            )
            let session = RecordingSessionProvider(
                initial: .authenticated(accessToken: "a", refreshToken: "r", expiresAt: Date().addingTimeInterval(3600))
            )
            let client = HTTPClient(config: config, sessionProvider: session, session: MockSession.make())
            return OrdersRepositoryImpl(client: client, cache: SdkCache())
        }

        private func settle(_ steps: [(statusCode: Int, json: String?)], timeout: Duration = .seconds(120)) async -> OrderSettlement {
            MockURLProtocol.reset()
            MockURLProtocol.handler = MockSession.sequence(steps)
            return await makeRepo().awaitSettlement(
                orderUUID: "order-1",
                interval: .seconds(3),
                timeout: timeout,
                sleep: { _ in }
            )
        }

        @Test("pendingThenFulfilledUsesProbe")
        func pendingThenFulfilledUsesProbe() async {
            let result = await settle([
                (200, PendingOrderJSON.make()),
                (200, OrderDetailJSON.make()),
                (200, OrderDetailJSON.make())
            ])
            guard case .fulfilled(let order) = result else {
                Issue.record("expected fulfilled, got \(result)")
                return
            }
            #expect(order.orderNumber == 1001)
            let requests = MockURLProtocol.capturedRequests
            #expect(requests.count == 3)
            #expect(requests.allSatisfy { $0.httpMethod == "GET" && $0.url?.path.contains("order-1") == true })
        }

        @Test("cancelledUnprovisionedOrderIsFailed")
        func cancelledUnprovisionedOrderIsFailed() async {
            let result = await settle([(200, PendingOrderJSON.make(orderStatus: "cancelled"))])
            guard case .failed(let order) = result else {
                Issue.record("expected failed, got \(result)")
                return
            }
            #expect(order == nil)
            #expect(MockURLProtocol.capturedRequests.count == 2)
        }

        @Test("paymentStatusFailedIsFailed")
        func paymentStatusFailedIsFailed() async {
            let result = await settle([(200, PendingOrderJSON.make(paymentStatus: "failed"))])
            guard case .failed = result else {
                Issue.record("expected failed, got \(result)")
                return
            }
            #expect(MockURLProtocol.capturedRequests.count == 2)
        }

        @Test("emptyPaymentStatusFallsBackToOrderStatus")
        func emptyPaymentStatusFallsBackToOrderStatus() async {
            let result = await settle([(200, OrderDetailJSON.make(orderStatus: "success", paymentStatus: ""))])
            guard case .fulfilled = result else {
                Issue.record("expected fulfilled, got \(result)")
                return
            }
        }

        @Test("decodeErrorsKeepPolling")
        func decodeErrorsKeepPolling() async {
            let result = await settle([
                (500, #"{"error":"server","detail":"down"}"#),
                (200, #"{"unexpected":true}"#),
                (200, OrderDetailJSON.make())
            ])
            guard case .fulfilled = result else {
                Issue.record("expected fulfilled, got \(result)")
                return
            }
            #expect(MockURLProtocol.capturedRequests.count == 4)
        }

        @Test("timesOutPendingWithoutDetail")
        func timesOutPendingWithoutDetail() async {
            let result = await settle([(200, PendingOrderJSON.make())], timeout: .zero)
            guard case .pending(let order) = result else {
                Issue.record("expected pending, got \(result)")
                return
            }
            #expect(order == nil)
            #expect(MockURLProtocol.capturedRequests.count == 1)
        }
    }
}
