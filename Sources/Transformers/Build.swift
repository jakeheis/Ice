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
        t.ignore(InternalTerminatedErrorLine.self)
        t.ignore(WarningsGeneratedLine.self)
        t.ignore(TerminatedLine.self)
        t.ignore(UnderscoreLine.self)
        t.add(InternalErrorResponse.self)
        t.add(LinkResponse.self)
    }
    
}

class InternalErrorResponse: SingleLineResponse {
    static func respond(to line: InternalErrorLine) {
        stderr <<< ""
        stderr <<< "Error: ".bold.red + line.message
        stderr <<< ""
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
    func consume(input: InputMatcher) {
        input.continueIf(CompileCLine.self, where: { $0.module == self.module })
        input.fallback(.stop)
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
    
    func consume(input: InputMatcher) {
        let indentation = "    "
        switch awaitingLine {
        case .code:
            if self.line.type == .note  {
                input.stopIf(CompileSwiftLine.self)
                input.stopIf(CompileCLine.self)
                input.stopIf(BuildErrorLine.self)
                input.stopIf(LinkLine.self)
                input.stopIf(WarningsGeneratedLine.self)
            }
            input.expect(CodeLine.self) { (line) in
                let text = line.text
                let lineStartIndex = text.index(where: { $0 != " " }) ?? text.startIndex
                stream <<< indentation + String(text[lineStartIndex...]).lightBlack
                awaitingLine = .highlightsOrCode(startIndex: lineStartIndex)
            }
        case let .highlightsOrCode(startIndex):
            input.expect(HighlightsLine.self) { (line) in
                stream <<< indentation + String(line.highlights[startIndex...]).replacingAll(matching: "~", with: "^").applyingColor(color)
                awaitingLine = .suggestionOrDone(startIndex: startIndex)
            }
            input.expect(CodeLine.self) { (line) in
                stream <<< indentation + String(line.text[startIndex...]).lightBlack
            }
        case let .suggestionOrDone(startIndex):
            input.stopIf(CompileSwiftLine.self)
            input.stopIf(CompileCLine.self)
            input.stopIf(BuildErrorLine.self)
            input.stopIf(LinkLine.self)
            input.stopIf(WarningsGeneratedLine.self)
            
            input.continueIf(WhitespaceErrLine.self)
            input.expect(SuggestionLine.self) { (line) in
                stream <<< indentation + String(line.text[startIndex...]).applyingColor(color) + "\n"
            }
        }

        input.fallback(.fatalError)
    }
    
    func finish() {
        let file = line.path.hasPrefix("/") ? line.path.beautifyPath : line.path
        stream <<< "    at \(file)" + ":\(line.lineNumber)\n"
    }
    
    
}
