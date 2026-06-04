//
//  TransactionType.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/06/04.
//

import Foundation

// MARK: Transaction Type Enum

public enum TransactionType: String, Codable {
    case buy = "buy"
    case topUp = "top-up"
}
