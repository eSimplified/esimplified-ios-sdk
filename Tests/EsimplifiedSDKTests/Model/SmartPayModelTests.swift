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
}
