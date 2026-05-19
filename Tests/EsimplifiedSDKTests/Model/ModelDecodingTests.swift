import Testing
import Foundation
@testable import EsimplifiedSDK

@Suite("Model Decoding")
struct ModelDecodingTests {

    private func decode<T: Decodable>(_ json: String) throws -> T {
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }

    @Test("Country decodes from JSON")
    func countryDecoding() throws {
        let json = """
        {"country_name":"Canada","country_code":"CA","country_name_slug":"canada","country_flag":"","country_flag_css":"","is_region":false}
        """
        let country: Country = try decode(json)
        #expect(country.countryName == "Canada")
        #expect(country.countryCode == "CA")
    }

    @Test("RegisterCustomerResponse handles null referral_code")
    func registerNullReferral() throws {
        let json = """
        {"message":"ok","success":true,"email":"test@test.com","referral_code":null}
        """
        let response: RegisterCustomerResponse = try decode(json)
        #expect(response.success == true)
        #expect(response.referralCode == nil)
    }

    @Test("RestrictedCountry decodes with nested objects")
    func restrictedCountryDecoding() throws {
        let json = """
        [{"country_code":"AE","restriction_type":"global","restricted_for":[]},{"country_code":"OM","restriction_type":"local","restricted_for":[{"country_code":"OM","country_name":"Oman"}]}]
        """
        let countries: [RestrictedCountry] = try decode(json)
        #expect(countries.count == 2)
        #expect(countries[0].restrictionType == .global)
    }
}
