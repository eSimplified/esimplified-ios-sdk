//
//  ModelDecodingTests.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/06/04.
//

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

    @Test("PackageDetail decodes package_country_code")
    func packageDetailCountryCode() throws {
        let json = """
        {"package_id":"d34ae82f","status":"ACTIVE","date_created_epoch":1787740202276,\
        "window_activation_start_epoch":1787740202276,"window_activation_end_epoch":1790332202276,\
        "voice_usage_remaining_seconds":0,"sms_usage_remaining_nums":0,"time_allowance_seconds":2592000,\
        "time_allowance_days":30,"package_country_name":"USA","package_country_code":"US",\
        "package_type_id":231551,"date_expiry_epoch":1790332202276,"date_activated_epoch":1787740202276,\
        "data_allowance_bytes":12884901888,"data_usage_bytes":0,"data_usage_remaining_bytes":12884901888,\
        "data_allowance_gigabytes":12,"status_message":"Active"}
        """
        let package: PackageDetail = try decode(json)
        #expect(package.packageCountryCode == "US")
        #expect(package.packageCountryName == "USA")
    }

    @Test("PackageDetail decodes without package_country_code")
    func packageDetailMissingCountryCode() throws {
        let json = """
        {"status":"ACTIVE","date_created_epoch":1787740202276,\
        "window_activation_start_epoch":1787740202276,"window_activation_end_epoch":1790332202276,\
        "voice_usage_remaining_seconds":0,"sms_usage_remaining_nums":0,"time_allowance_seconds":2592000,\
        "time_allowance_days":30,"package_country_name":"USA","package_type_id":231551,\
        "data_allowance_bytes":12884901888,"data_usage_remaining_bytes":12884901888,\
        "data_allowance_gigabytes":12,"status_message":"Active"}
        """
        let package: PackageDetail = try decode(json)
        #expect(package.packageCountryCode == nil)
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

// MARK: - Order eSIM Name

@Suite("Order eSIM Info")
struct OrderEsimInfoDecodingTests {

    private func decode(_ json: String) throws -> EsimInfo {
        try JSONDecoder().decode(EsimInfo.self, from: Data(json.utf8))
    }

    @Test("Decodes the customer's eSIM name straight off the order")
    func decodesEsimName() throws {
        let esim = try decode("""
        {
          "id": 4257,
          "iccid": "250700000031473",
          "country": "Andorra",
          "matching_id": "25011473",
          "android_sha": false,
          "sm_dp_address": "test.esim.com",
          "assigned_date": "2026-08-20T12:44:23.339874Z",
          "premium": false,
          "archived": false,
          "esim_name": "Kieran's eSIM",
          "is_universal": true
        }
        """)

        #expect(esim.esimName == "Kieran's eSIM")
        #expect(esim.isUniversal == true)
        #expect(esim.iccid == "250700000031473")
    }

    @Test("Decodes a legacy eSIM's name and flags it non-universal")
    func decodesLegacyEsimName() throws {
        let esim = try decode("""
        {
          "iccid": "260700000049466",
          "country": "USA",
          "matching_id": "26029466",
          "android_sha": false,
          "sm_dp_address": "test.esim.com",
          "assigned_date": "2026-08-25T14:13:09.443444Z",
          "premium": false,
          "esim_name": "Kirrie’s device",
          "is_universal": false
        }
        """)

        #expect(esim.esimName == "Kirrie’s device")
        #expect(esim.isUniversal == false)
    }

    @Test("A null name decodes as nil rather than failing")
    func nullEsimNameIsNil() throws {
        let esim = try decode("""
        {
          "iccid": "100700000128227",
          "country": "Afghanistan",
          "matching_id": "10108227",
          "android_sha": false,
          "sm_dp_address": "test.esim.com",
          "assigned_date": "2026-08-20T12:49:18.009066Z",
          "premium": false,
          "esim_name": null,
          "is_universal": false
        }
        """)

        #expect(esim.esimName == nil)
        #expect(esim.country == "Afghanistan")
    }

    @Test("Missing keys decode as nil, so existing payloads keep working")
    func missingKeysDecode() throws {
        let esim = try decode("""
        {
          "iccid": "1",
          "country": "Global",
          "matching_id": "2",
          "android_sha": false,
          "sm_dp_address": "a",
          "assigned_date": "b",
          "premium": false
        }
        """)

        #expect(esim.esimName == nil)
        #expect(esim.isUniversal == nil)
    }
}
