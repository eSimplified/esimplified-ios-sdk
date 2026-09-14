//
//  TermsOutline.swift
//  EsimplifiedSDK
//  Created by Zivaiishe Kanengoni on 2026/09/09.
//

import Foundation

// MARK: Terms Outline

enum TermsOutline {

    static let sectionIds: [String] = [
        "generalTerms", "eligibility", "gcc", "ukEurope", "visaPremier", "visaPlatinum", "conditions", "vouchers", "kreds"
    ]

    static let itemDepths: [String: [Int]] = [
        "generalTerms": [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
        "eligibility": [1, 2, 2, 2, 2, 1, 1],
        "gcc": [1, 2, 3, 3, 3, 2, 3, 3, 3, 3, 3, 3, 3, 3],
        "ukEurope": [1, 1, 2, 3, 3, 3, 2, 3, 3, 3, 3, 3, 3, 3, 3, 1, 2, 3, 3, 3, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 1, 2, 3, 3, 3, 2, 3, 3, 3, 3, 3, 3, 3, 3, 1, 2, 3, 3, 3, 2, 3, 3, 3, 3, 3, 3, 3, 3, 1, 2, 3, 3, 3, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 1, 2, 3, 3, 3, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 1, 2, 3, 3, 3, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 1, 2, 3, 3, 3, 2, 3, 3, 3, 3, 3, 3, 3, 3, 1, 2, 3, 3, 3, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3],
        "visaPremier": [1, 2, 2, 2, 2],
        "visaPlatinum": [1, 2, 2, 2, 2],
        "conditions": [1, 1, 1],
        "vouchers": [1, 1],
        "kreds": [1, 1, 1, 2, 2, 2, 2, 2, 2, 1, 2, 2, 1, 1, 1, 2, 2, 1, 1, 1, 1, 2, 2, 2, 2, 2, 1, 1, 1, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2]
    ]

    static let sublistMarkers: [String: TermsSublistMarker] = [
        "generalTerms": .disc,
        "eligibility": .disc,
        "gcc": .alpha,
        "ukEurope": .alpha,
        "visaPremier": .alpha,
        "visaPlatinum": .alpha,
        "conditions": .disc,
        "vouchers": .disc,
        "kreds": .disc
    ]

    static let bodyKeys: [String: [String]] = [
        "generalTerms": ["body1", "body2", "body3"],
        "eligibility": ["body1"],
        "gcc": ["body1"],
        "ukEurope": ["body1", "body2", "body3", "body4", "body5", "body6", "body7", "body8", "body9"],
        "visaPremier": ["body1"],
        "visaPlatinum": ["body1"],
        "conditions": ["body1"],
        "vouchers": ["body1"],
        "kreds": ["body1", "body2", "body3"]
    ]
}
