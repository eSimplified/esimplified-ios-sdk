//
//  OrderSettlement.swift
//  EsimplifiedSDK
//

import Foundation

public enum OrderSettlement {
    case fulfilled(OrderDetail)
    case failed(OrderDetail?)
    case pending(OrderDetail?)
}

public extension OrderDetail {
    var isSettlementFailure: Bool {
        SettlementRules.isFailure(orderStatus: orderStatus, paymentStatus: paymentStatus)
    }

    var isFulfilled: Bool {
        SettlementRules.isFulfilled(orderStatus: orderStatus, paymentStatus: paymentStatus, iccid: iccid)
    }
}

struct OrderStatusProbe: Decodable {
    let orderStatus: String
    let paymentStatus: String?
    let iccid: String?

    enum CodingKeys: String, CodingKey {
        case iccid
        case orderStatus = "order_status"
        case paymentStatus = "payment_status"
    }

    var isSettlementFailure: Bool {
        SettlementRules.isFailure(orderStatus: orderStatus, paymentStatus: paymentStatus)
    }

    var isFulfilled: Bool {
        SettlementRules.isFulfilled(orderStatus: orderStatus, paymentStatus: paymentStatus, iccid: iccid)
    }
}

enum SettlementRules {
    private static let terminal: Set<String> = ["failed", "cancelled", "canceled", "declined", "expired"]

    static func isFailure(orderStatus: String, paymentStatus: String?) -> Bool {
        if let payment = normalized(paymentStatus), terminal.contains(payment) { return true }
        return terminal.contains(orderStatus.lowercased())
    }

    static func isFulfilled(orderStatus: String, paymentStatus: String?, iccid: String?) -> Bool {
        guard let iccid, !iccid.isEmpty else { return false }
        if let payment = normalized(paymentStatus) { return payment == "success" }
        return orderStatus.lowercased() == "success"
    }

    private static func normalized(_ status: String?) -> String? {
        guard let trimmed = status?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmed.isEmpty else {
            return nil
        }
        return trimmed.lowercased()
    }
}
