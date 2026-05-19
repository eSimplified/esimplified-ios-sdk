import Testing
@testable import EsimplifiedSDK

@Suite("SDK Version")
struct EsimplifiedSDKTests {
    @Test("Version is 1.0.0")
    func version() {
        #expect(EsimplifiedSDKVersion.version == "1.0.0")
    }
}
