//
//  Extensions.swift
//  Transformers
//
//  Created by Jake Heiser on 9/12/17.
//

import Foundation
import Rainbow
import Regex
import SwiftCLI

// MARK: - Extensions

public extension String {
    
    var beautifyPath: String {
        var improved = self
        let workingDirPrefix = FileManager.default.currentDirectoryPath
        if hasPrefix(workingDirPrefix) {
            improved = String(self[index(startIndex, offsetBy: workingDirPrefix.count + 1)...])
        }
        var components = improved.components(separatedBy: "/")
        let last = components.removeLast()
        return components.joined(separator: "/").dim + "/\(last)"
    }
    
    var trimmed: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Lines

final class InternalErrorLine: Matcher, Matchable {
    static let regex = Regex("error: (.*)$")
    var message: String { return captures[0] }
    
    func print(to out: WritableStream) {
        out <<< ""
        out <<< "Error: ".bold.red + message
        out <<< ""
    }
}

final class InternalWarningLine: Matcher, Matchable {
    static let regex = Regex("warning: (.*)$")
    var message: String { return captures[0] }
    
    func print(to out: WritableStream) {
        out <<< ""
        out <<< "Warning: ".bold.yellow + message
        out <<< ""
    }
}

final class InternalNoteLine: Matcher, Matchable {
    static let regex = Regex("^note: (.*)$")
    var message: String { return captures[0] }
}
