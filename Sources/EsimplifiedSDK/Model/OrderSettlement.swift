//
//  OrderSettlement.swift
//  EsimplifiedSDK
//

import Foundation

public enum OrderSettlement {
    case fulfilled(OrderDetail)
    case failed(OrderDetail)
    case pending(OrderDetail?)
}

public extension OrderDetail {
    var isSettlementFailure: Bool {
        let terminal: Set<String> = ["failed", "cancelled", "canceled", "declined", "expired"]
        if let paymentStatus, terminal.contains(paymentStatus.lowercased()) { return true }
        return terminal.contains(orderStatus.lowercased())
    }

    var isFulfilled: Bool {
        guard let iccid, !iccid.isEmpty else { return false }
        if let paymentStatus { return paymentStatus.lowercased() == "success" }
        return orderStatus.lowercased() == "success"
    }
}
