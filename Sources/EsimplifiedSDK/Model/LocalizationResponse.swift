//
//  LocalizationResponse.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/11/18.
//

import Foundation

// MARK: Localization

public struct Localization: Codable, Hashable, Sendable {
    public let defaultCurrency: String?
    public let currencies: [SupportedCurrency]
    public let defaultLanguage: String?
    public let languages: [SupportedLanguage]

    private enum CodingKeys: String, CodingKey {
        case defaultCurrency = "default_currency"
        case currencies
        case defaultLanguage = "default_language"
        case languages
    }

    public init(
        defaultCurrency: String? = nil,
        currencies: [SupportedCurrency] = [],
        defaultLanguage: String? = nil,
        languages: [SupportedLanguage] = []
    ) {
        self.defaultCurrency = defaultCurrency
        self.currencies = currencies
        self.defaultLanguage = defaultLanguage
        self.languages = languages
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        defaultCurrency = try container.decodeIfPresent(String.self, forKey: .defaultCurrency)
        currencies = try container.decodeIfPresent([SupportedCurrency].self, forKey: .currencies) ?? []
        defaultLanguage = try container.decodeIfPresent(String.self, forKey: .defaultLanguage)
        languages = try container.decodeIfPresent([SupportedLanguage].self, forKey: .languages) ?? []
    }
}

// MARK: Localization Include

public enum LocalizationInclude: String, Sendable {
    case currencies
    case languages
}

// MARK: Supported Currency

public struct SupportedCurrency: Codable, Hashable, Sendable {
    public let code: String
    public let name: String?
    public let symbol: String?

    public init(code: String, name: String? = nil, symbol: String? = nil) {
        self.code = code
        self.name = name
        self.symbol = symbol
    }
}

// MARK: Supported Language

public struct SupportedLanguage: Codable, Hashable, Sendable {
    public let code: String
    public let name: String?

    public init(code: String, name: String? = nil) {
        self.code = code
        self.name = name
    }
}
