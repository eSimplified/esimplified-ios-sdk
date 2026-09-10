//
//  ContentEnvelope.swift
//  EsimplifiedSDK
//  Created by Zivaiishe Kanengoni on 2026/09/09.
//

import Foundation

// MARK: Content Envelope

struct ContentEnvelope<Content: Decodable & Sendable>: Decodable, Sendable {

    let language: String
    let content: Content
}
