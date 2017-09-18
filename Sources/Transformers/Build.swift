//
//  Build.swift
//  Transformers
//
//  Created by Jake Heiser on 9/12/17.
//

import Exec
import Regex
import Rainbow
import Foundation
import SwiftCLI

public extension Transformers {
    
    static func build(t: OutputTransformer) {
        t.replace(CompileMatch.self, on: .out) { "Compile ".dim + "\($0.module) \($0.sourceCount)" }
        t.register(CompileCResponse.self, on: .out)
        t.register(ErrorResponse.self, on: .out)
        t.replace(InternalErrorMatch.self, on: .err) { "\nError: ".bold.red + $0.message }
        t.ignore(ErrorResponse.oldCompletionRegex, on: .out)
        t.ignore("^terminated\\(1\\)", on: .err)
        t.ignore("^\\s*_?\\s*$", on: .out)
        t.replace(LinkMatch.self, on: .out) { "Link ".blue + $0.product }
    }
    
}

final class InternalErrorMatch: Matcher {
    static let regex = Regex("^error: (.*)$")
    var message: String { return captures[0] }
}

final class CompileMatch: Matcher {
    static let regex = Regex("^Compile Swift Module '(.*)' (.*)$")
    var module: String { return captures[0] }
    var sourceCount: String { return captures[1] }
}

final class LinkMatch: Matcher {
    static let regex = Regex("^Linking (.*)")
    var product: String { return captures[0] }
}

final class CompileCResponse: SimpleResponse {
    
    final class Match: Matcher {
        static let regex = Regex("Compile ([^ ]*) .*\\.(c|m|cpp|mm)$")
        var module: String { return captures[0] }
    }
    
    let module: String
    
    init(match: Match) {
        self.module = match.module
    }

    func go() {
        stdout <<< "Compile ".dim + "\(module)"
    }
    
    func keepGoing(on line: String) -> Bool {
        return line.hasPrefix("Compile \(module) ")
    }
    
    func stop() {}
    
}

class ErrorTracker {

    static var past: [ErrorResponse.Match] = []
    
    static var skippingCurrent = false

    static func shouldSkip(_ match: ErrorResponse.Match) -> Bool {
        if match.type == .note {
            return skippingCurrent
        } else {
            skippingCurrent = past.contains(match)
            return skippingCurrent
        }
    }
    
    static func record(_ match: ErrorResponse.Match) {
        past.append(match)
    }

}

final class ErrorResponse: SimpleResponse {
    
    final class Match: Matcher, Equatable {
        static let regex = Regex("^(/.*):([0-9]+):([0-9]+): (error|warning|note): (.*)$")
        
        enum ErrorType: String, Capturable {
            case error
            case warning
            case note
        }
        
        var path: String { return captures[0] }
        var lineNumber: Int { return captures[1] }
        var columnNumber: Int { return captures[2] }
        var type: ErrorType { return captures[3] }
        var message: String { return captures[4] }
    }
    
    static let oldCompletionRegex = Regex("^[0-9]+ warnings? generated\\.$")
    
    enum AwaitingLine {
        case code
        case highlightsOrCode(startIndex: String.Index)
        case suggestionOrDone(startIndex: String.Index)
    }
    
    let match: Match
    let color: Color
    let stream: OutputByteStream
    
    var awaitingLine: AwaitingLine = .code
    
    init(match: Match) {
        self.match = match
        switch match.type {
        case .error:
            self.color = .red
        case .warning:
            self.color = .yellow
        case .note:
            self.color = .yellow
        }
        
        if ErrorTracker.shouldSkip(match) {
            self.stream = NullStream()
        } else {
            self.stream = OutputTransformer.stdout
            ErrorTracker.record(match)
        }
    }
    
    func go() {
        let prefix: String
        switch match.type {
        case .error:
            prefix = "\n  ● Error:".red.bold
        case .warning:
            prefix = "\n  ● Warning:".yellow.bold
        case .note:
            prefix = "    Note:".blue
        }
        stream <<< "\(prefix) \(match.message)"
        stream <<< ""
    }
    
    func keepGoing(on line: String) -> Bool {
        let matchesOther = CompileMatch.matches(line) || CompileCResponse.Match.matches(line) || ErrorResponse.Match.matches(line) ||
            LinkMatch.matches(line) || ErrorResponse.oldCompletionRegex.matches(line)
        
        let indentation = "    "
        switch awaitingLine {
        case .code:
            if match.type == .note && matchesOther {
                // Notes don't always have associated code
                return false
            }
            let lineStartIndex = line.index(where: { $0 != " " }) ?? line.startIndex
            stream <<< indentation + String(line[lineStartIndex...]).lightBlack
            awaitingLine = .highlightsOrCode(startIndex: lineStartIndex)
        case let .highlightsOrCode(startIndex):
            if line.trimmingCharacters(in: CharacterSet(charactersIn: " ~^")).isEmpty {
                // It's a highlight line
                stream <<< indentation + String(line[startIndex...]).replacingAll(matching: "~", with: "^").applyingColor(color)
                awaitingLine = .suggestionOrDone(startIndex: startIndex)
            } else {
                // It's another code line
                stream <<< indentation + String(line[startIndex...]).lightBlack
            }
        case let .suggestionOrDone(startIndex):
            if matchesOther {
                // This error is done
                return false
            }
            if let characterIndex = line.index(where: { $0 != " " }), characterIndex >= startIndex {
                // If there's a bunch of whitespace first, it's likely a suggestion
                stream <<< indentation + String(line[startIndex...]).applyingColor(color) + "\n"
                return true
            }
            return false
        }
        return true
    }
    
    func stop() {
        let file = match.path.beautifyPath
        stream <<< "    at \(file)" + ":\(match.lineNumber)\n"
    }
    
    
}

