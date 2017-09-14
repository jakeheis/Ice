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

public extension Transformers {
    
    static func build(t: OutputTransformer) {
        t.replace(CompileMatch.self) { "Compile ".dim + "\($0.module) \($0.sourceCount)" }
        t.replace(CompileCMatch.self) { "Compile ".dim + "\($0.module)" }
        t.register(ErrorResponse.self, on: .out)
        t.ignore("^error:", on: .err)
        t.ignore("^terminated\\(1\\)", on: .err)
        t.ignore("^\\s*_\\s*$")
        t.replace(LinkMatch.self) { "Link ".blue + $0.product }
    }
    
}

private class CompileMatch: RegexMatch, Matchable {
    static let regex = Regex("Compile Swift Module '(.*)' (.*)$")
    var module: String { return captures[0] }
    var sourceCount: String { return captures[1] }
}

private class CompileCMatch: RegexMatch, Matchable {
    static let regex = Regex("Compile ([^ ]*) .*\\.c$")
    var module: String { return captures[0] }
}

private class LinkMatch: RegexMatch, Matchable {
    static let regex = Regex("Linking (.*)")
    var product: String { return captures[0] }
}

private final class ErrorResponse: SimpleResponse {
    
    class Match: RegexMatch, Matchable {
        static let regex = Regex("(/.*):([0-9]+):([0-9]+): (error|warning|note): (.*)")
        
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
    
    private static var pastMatches: [Match] = []
    
    enum AwaitingLine {
        case code
        case highlightsOrCode(startIndex: String.Index)
        case suggestionOrDone(startIndex: String.Index)
    }
    
    let match: Match
    let color: Color
    let stream: StdStream
    
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
        
        if ErrorResponse.pastMatches.contains(match) {
            self.stream = .null
        } else {
            self.stream = .out
            ErrorResponse.pastMatches.append(match)
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
        stream.output("\(prefix) \(match.message)\n")
    }
    
    func keepGoing(on line: String) -> Bool {
        let indentation = "    "
        switch awaitingLine {
        case .code:
            let lineStartIndex = line.index(where: { $0 != " " }) ?? line.startIndex
            stream.output(indentation + String(line[lineStartIndex...]).lightBlack)
            awaitingLine = .highlightsOrCode(startIndex: lineStartIndex)
        case let .highlightsOrCode(startIndex):
            if line.trimmingCharacters(in: CharacterSet(charactersIn: " ~^")).isEmpty {
                // It's a highlight line
                stream.output(indentation + String(line[startIndex...]).replacingAll(matching: "~", with: "^").applyingColor(color))
                awaitingLine = .suggestionOrDone(startIndex: startIndex)
            } else {
                // It's another code line
                stream.output(indentation + String(line[startIndex...]).lightBlack)
            }
        case let .suggestionOrDone(startIndex):
            if line.hasPrefix("/") || line.hasPrefix("error:") {
                // It's a new error
                return false
            }
            if let characterIndex = line.index(where: { $0 != " " }), characterIndex >= startIndex {
                // If there's a bunch of whitespace first, it's likely a suggestion
                stream.output(indentation + String(line[startIndex...]).applyingColor(color) + "\n")
                return true
            }
            return false
        }
        return true
    }
    
    func stop() {
        let file = match.path.beautifyPath
        stream.output("    at \(file)" + ":\(match.lineNumber)\n")
    }
    
    
}

