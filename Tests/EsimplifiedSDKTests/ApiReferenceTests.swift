//
//  ApiReferenceTests.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/09/16.
//

import Foundation
import Testing
@testable import EsimplifiedSDK

@Suite("API Reference")
struct ApiReferenceTests {

    @Test("Every repository table lists each method once, with the signature clients call")
    func tablesMatchTheProtocols() throws {
        let reference = try String(contentsOf: Self.root.appending(path: "SDK_API_REFERENCE.md"), encoding: .utf8)
        var checked = 0

        for block in reference.components(separatedBy: "\n### ").dropFirst() {
            guard let heading = block.components(separatedBy: "\n").first?.trimmingCharacters(in: .whitespaces),
                  block.contains("| Method | Signature |") else { continue }

            let source = Self.root.appending(path: "Sources/EsimplifiedSDK/Repository/\(heading)Type.swift")
            guard FileManager.default.fileExists(atPath: source.path()) else { continue }

            let expected = Self.rows(for: try String(contentsOf: source, encoding: .utf8))
            let documented = block
                .components(separatedBy: "\n")
                .filter { $0.hasPrefix("| `") }

            let stale = documented.filter { !expected.contains($0) }
            let missing = expected.filter { !documented.contains($0) }

            #expect(stale.isEmpty, "\(heading) documents a signature the protocol does not have:\n\(stale.joined(separator: "\n"))")
            #expect(missing.isEmpty, "\(heading) is missing:\n\(missing.joined(separator: "\n"))")
            #expect(documented.count == expected.count, "\(heading) lists \(documented.count) rows for \(expected.count) methods")

            checked += 1
        }

        #expect(checked == 15)
    }

    private static var root: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private static func rows(for source: String) -> [String] {
        var signatures: [String: [String]] = [:]
        let lines = source.components(separatedBy: "\n")

        for (index, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard trimmed.hasPrefix("func "),
                  let opening = trimmed.firstIndex(of: "(") else { continue }

            let name = String(trimmed[trimmed.index(trimmed.startIndex, offsetBy: 5)..<opening])
            var signature = trimmed
            var cursor = index + 1
            while signature.filter({ $0 == "(" }).count > signature.filter({ $0 == ")" }).count, cursor < lines.count {
                signature += " " + lines[cursor].trimmingCharacters(in: .whitespaces)
                cursor += 1
            }

            signatures[name, default: []].append(normalised(signature))
        }

        return signatures
            .sorted { $0.key < $1.key }
            .map { "| `\($0.key)` | `\(preferred(among: $0.value))` |" }
    }

    private static func normalised(_ signature: String) -> String {
        var collapsed = signature.components(separatedBy: .whitespaces).filter { !$0.isEmpty }.joined(separator: " ")
        if let body = collapsed.range(of: " {") {
            collapsed = String(collapsed[collapsed.startIndex..<body.lowerBound])
        }
        return collapsed.replacingOccurrences(of: "( ", with: "(").replacingOccurrences(of: " )", with: ")")
    }

    private static func preferred(among signatures: [String]) -> String {
        signatures.sorted {
            let defaults = ($0.components(separatedBy: " = ").count, $1.components(separatedBy: " = ").count)
            if defaults.0 != defaults.1 { return defaults.0 > defaults.1 }
            return $0.count < $1.count
        }[0]
    }
}
