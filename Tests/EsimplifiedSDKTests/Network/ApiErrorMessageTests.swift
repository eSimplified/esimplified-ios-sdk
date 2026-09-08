//
//  ApiErrorMessageTests.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/09/07.
//

import Testing
import Foundation
@testable import EsimplifiedSDK

@Suite("Api Error Message")
struct ApiErrorMessageTests {

    private func parse(_ json: String) -> String {
        ApiErrorMessage.parse(Data(json.utf8))
    }

    @Test("message key wins")
    func messageKey() {
        #expect(parse(#"{"message":"Card declined"}"#) == "Card declined")
    }

    @Test("detail key is used when message is absent")
    func detailKey() {
        #expect(parse(#"{"detail":"Not found."}"#) == "Not found.")
    }

    @Test("field errors are labelled with the field name")
    func fieldErrors() {
        #expect(parse(#"{"phone_number":["This field may not be blank."]}"#) == "Phone number: This field may not be blank.")
    }

    @Test("multiple field errors are listed one per line, sorted by field")
    func multipleFieldErrors() {
        let message = parse(#"{"phone_number":["Enter a valid phone number."],"email":["Enter a valid email address."]}"#)
        #expect(message == "Email: Enter a valid email address.\nPhone number: Enter a valid phone number.")
    }

    @Test("non_field_errors are not labelled")
    func nonFieldErrors() {
        #expect(parse(#"{"non_field_errors":["Unable to log in with provided credentials."]}"#) == "Unable to log in with provided credentials.")
    }

    @Test("nested error objects are flattened")
    func nestedErrors() {
        #expect(parse(#"{"errors":{"phone_number":["Required."]}}"#) == "Phone number: Required.")
    }

    @Test("plain text bodies are returned as is")
    func plainText() {
        #expect(parse("Bad Gateway") == "Bad Gateway")
    }

    @Test("empty bodies fall back")
    func emptyBody() {
        #expect(parse("") == ApiErrorMessage.fallback)
        #expect(parse("{}") == ApiErrorMessage.fallback)
    }
}
