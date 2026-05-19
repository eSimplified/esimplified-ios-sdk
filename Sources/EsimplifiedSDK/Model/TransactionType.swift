//
//  TransactionType.swift
//  EsimplifiedSDK
//

import Foundation

// MARK: Transaction Type Enum

public enum TransactionType: String, Codable {
    case buy = "buy"
    case topUp = "top-up"
}
