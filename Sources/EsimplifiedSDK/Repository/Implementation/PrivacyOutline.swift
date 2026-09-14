//
//  PrivacyOutline.swift
//  EsimplifiedSDK
//  Created by Zivaiishe Kanengoni on 2026/09/09.
//

import Foundation

// MARK: Privacy Outline

enum PrivacyOutline {

    static let sectionIds: [String] = [
        "introduction",
        "changes",
        "collection",
        "whatWeCollect",
        "howWeUse",
        "cookies",
        "disclosure",
        "thirdParties",
        "children",
        "security",
        "rights",
        "complaints",
        "international",
        "contact"
    ]

    static let blockKinds: [String: [PolicyBlockKind]] = [
        "introduction": [.paragraph, .paragraph],
        "changes": [.paragraph],
        "collection": [.paragraph, .paragraph],
        "whatWeCollect": [.paragraph, .heading, .paragraph, .heading, .paragraph, .listItem, .listItem, .listItem, .listItem, .listItem, .paragraph, .heading, .paragraph, .listItem, .listItem, .listItem],
        "howWeUse": [.paragraph, .listItem, .listItem, .listItem, .listItem],
        "cookies": [.paragraph, .paragraph],
        "disclosure": [.paragraph, .listItem, .listItem, .listItem, .listItem, .paragraph, .heading, .listItem, .listItem, .listItem, .heading, .listItem, .listItem, .listItem, .paragraph],
        "thirdParties": [.paragraph],
        "children": [.paragraph, .paragraph],
        "security": [.paragraph, .paragraph],
        "rights": [.paragraph, .listItem, .listItem, .listItem, .listItem, .paragraph, .paragraph],
        "complaints": [.paragraph],
        "international": [.paragraph, .paragraph],
        "contact": [.paragraph]
    ]

    static let bodyKeys: [String: [String]] = [
        "introduction": ["body1"],
        "changes": ["body1"],
        "collection": ["body1"],
        "whatWeCollect": ["body1", "body2"],
        "howWeUse": ["body1"],
        "cookies": ["body1"],
        "disclosure": ["body1", "body2"],
        "thirdParties": ["body1"],
        "children": ["body1"],
        "security": ["body1"],
        "rights": ["body1"],
        "complaints": ["body1"],
        "international": ["body1"],
        "contact": ["body1"]
    ]
}
