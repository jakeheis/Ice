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
        t.add(CompileSwiftResponse.self)
        t.add(CompileCResponse.self)
        t.add(ErrorResponse.self)
        t.add(InternalErrorResponse.self)
        t.ignore(WarningsGeneratedLine.self)
        t.ignore(TerminatedLine.self)
        t.ignore(UnderscoreLine.self)
        t.ignore(WhitespaceOutLine.self)
        t.add(LinkResponse.self)
    }
    
}

class InternalErrorResponse: SingleLineResponse {
    static func respond(to line: InternalErrorLine) {
        stderr <<< "\nError: ".bold.red + line.message
    }
}

class CompileSwiftResponse: SingleLineResponse {
    static func respond(to line: CompileSwiftLine) {
        stdout <<< "Compile ".dim + "\(line.module) \(line.sourceCount)"
    }
}

class LinkResponse: SingleLineResponse {
    static func respond(to line: LinkLine) {
        stdout <<< "Link ".blue + line.product
    }
}

final class CompileCResponse: MultiLineResponse {
    let module: String
    init(line: CompileCLine) {
        self.module = line.module
        stdout <<< "Compile ".dim + "\(line.module)"
    }
    func consume(line: String) -> Bool {
        if let continued = CompileCLine.findMatch(in: line),
            continued.module == self.module {
            return true
        }
        return false
    }
}

class ErrorTracker {
    
    static var past: [BuildErrorLine] = []
    
    static var skippingCurrent = false
    
    static func shouldSkip(_ line: BuildErrorLine) -> Bool {
        if line.type == .note {
            return skippingCurrent
        } else {
            skippingCurrent = past.contains(line)
            return skippingCurrent
        }
    }
    
    static func record(_ line: BuildErrorLine) {
        past.append(line)
    }
    
}

final class ErrorResponse: MultiLineResponse {
    
    enum AwaitingLine {
        case code
        case highlightsOrCode(startIndex: String.Index)
        case suggestionOrDone(startIndex: String.Index)
    }
    
    let line: BuildErrorLine
    let color: Color
    let stream: OutputByteStream
    
    var awaitingLine: AwaitingLine = .code
    
    init(line: BuildErrorLine) {
        self.line = line
        
        if ErrorTracker.shouldSkip(line) {
            self.stream = NullStream()
        } else {
            self.stream = OutputTransformer.stdout
            ErrorTracker.record(line)
        }
        
        let prefix: String
        switch line.type {
        case .error:
            self.color = .red
            prefix = "\n  ● Error:".red.bold
        case .warning:
            self.color = .yellow
            prefix = "\n  ● Warning:".yellow.bold
        case .note:
            self.color = .yellow
            prefix = "    Note:".blue
        }
        
        stream <<< "\(prefix) \(line.message)"
        stream <<< ""
    }
    
    func consume(line: String) -> Bool {
        let matchesOther = CompileSwiftLine.matches(line) || CompileCLine.matches(line) || BuildErrorLine.matches(line) ||
            LinkLine.matches(line) || WarningsGeneratedLine.matches(line)
        
        let indentation = "    "
        switch awaitingLine {
        case .code:
            if self.line.type == .note && matchesOther {
                // Notes don't always have associated code
                return false
            }
            let lineStartIndex = line.index(where: { $0 != " " }) ?? line.startIndex
            stream <<< indentation + String(line[lineStartIndex...]).lightBlack
            awaitingLine = .highlightsOrCode(startIndex: lineStartIndex)
        case let .highlightsOrCode(startIndex):
            if HighlightsLine.matches(line) {
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
    
    func finish() {
        let file = line.path.beautifyPath
        stream <<< "    at \(file)" + ":\(line.lineNumber)\n"
    }
    
    
}
