import Testing
import Foundation
@testable import EsimplifiedSDK

@Suite("SmartPay models")
struct SmartPayModelTests {
    @Test("PaymentMethod decodes smartpay")
    func decodesSmartPay() throws {
        let method = try JSONDecoder().decode(PaymentMethod.self, from: Data(#""smartpay""#.utf8))
        #expect(method == .smartpay)
        #expect(method.displayName == "SmartPay")
        #expect(method.shouldShowAmount)
    }

    @Test("PaymentRequest encodes smartpay and redirect_url")
    func encodesSmartPayRequest() throws {
        let request = PaymentRequest(type: .buy, payment_method: .smartpay, package_type_id: "46576",
                                     customer: CustomerEmail(email: "c@example.com"), auto_top_up: false,
                                     redirect_url: "https://osim-preview.vercel.app/order")
        let json = try JSONSerialization.jsonObject(with: JSONEncoder().encode(request)) as? [String: Any]
        #expect(json?["payment_method"] as? String == "smartpay")
        #expect(json?["redirect_url"] as? String == "https://osim-preview.vercel.app/order")
    }

    @Test("Stripe PaymentRequest omits redirect_url")
    func stripeRequestOmitsRedirect() throws {
        let request = PaymentRequest(type: .buy, package_type_id: "1", customer: CustomerEmail(email: "c@example.com"))
        let json = try JSONSerialization.jsonObject(with: JSONEncoder().encode(request)) as? [String: Any]
        #expect(json?["redirect_url"] == nil)
    }

    @Test("OrderDetail decodes payment_status when present and nil when absent")
    func decodesPaymentStatus() throws {
        let with = try JSONDecoder().decode(OrderDetail.self, from: Data(OrderDetailJSON.make(paymentStatus: "failed").utf8))
        #expect(with.paymentStatus == "failed")
        let without = try JSONDecoder().decode(OrderDetail.self, from: Data(OrderDetailJSON.make(paymentStatus: nil).utf8))
        #expect(without.paymentStatus == nil)
    }
}
