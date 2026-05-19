//
//  StringExtensions.swift
//  EsimplifiedSDK
//

import Foundation

extension String {
    var formattedPackageName: String {
        let tokens = self.components(separatedBy: " ")
        guard tokens.count >= 4 else { return self }
        return "\(tokens[tokens.count - 4]) \(tokens[tokens.count - 3]) Data \(tokens[tokens.count - 2]) \(tokens[tokens.count - 1])"
    }
}
