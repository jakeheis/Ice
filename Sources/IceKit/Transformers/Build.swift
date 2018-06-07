//
//  Build.swift
//  Transformers
//
//  Created by Jake Heiser on 9/12/17.
//

import Foundation
import Rainbow
import Regex
import SwiftCLI

extension TransformerPair {
    static var build: TransformerPair { return TransformerPair(out: BuildOut(), err: BuildErr()) }
}

class BuildOut: BaseTransformer {
    
    private let errorTracker = ErrorTracker()
    
    public func go(stream: TransformStream) {
        if let compileSwift = stream.match(CompileSwiftLine.self) {
            stdout <<< "Compile ".dim + "\(compileSwift.module) \(compileSwift.sourceCount)"
        } else if let compileC = stream.match(CompileCLine.self) {
            stdout <<< "Compile ".dim + "\(compileC.module)"
            
            while stream.nextIs(CompileCLine.self, where: { $0.module == compileC.module }) {
                stream.consume()
            }
        } else if let link = stream.match(LinkLine.self) {
            stdout <<< "Link ".blue + link.product
        } else if stream.nextIs(BuildErrorLine.self) {
            Error(errorTracker: errorTracker).go(stream: stream)
        } else if stream.nextIs(in: [WarningsGeneratedLine.self, UnderscoreLine.self]) {
            stream.consume()
        } else if let line = stream.match(UnknownErrorLine.self) {
            stdout.print(type: line.type, message: line.message)
        } else if let linkerError = stream.match(LinkerErrorStartLine.self) {
            stdout <<< linkerError.text
            while stream.isOpen() && !stream.nextIs(LinkerErrorEndLine.self) {
                let line = stream.require(AnyLine.self)
                stdout <<< line.text
            }
            let line = stream.require(AnyLine.self)
            stdout <<< line.text
        }
    }
    
}

class BuildErr: BaseTransformer {
    func go(stream: TransformStream) {
        if stream.nextIs(in: [InternalTerminatedErrorLine.self, TerminatedLine.self, WhitespaceLine.self]) {
            stream.consume()
        } else if let internalError = stream.match(InternalErrorLine.self) {
            internalError.print(to: stderr)
        } else if let internalWarning = stream.match(InternalWarningLine.self) {
            internalWarning.print(to: stderr)
        }
    }
}

private class Error: Transformer {
    
    private let indentation = "    "
    private let stopLines: [Line.Type] = [CompileSwiftLine.self, CompileCLine.self, BuildErrorLine.self, LinkLine.self, WarningsGeneratedLine.self]
    
    let errorTracker: ErrorTracker
    
    init(errorTracker: ErrorTracker) {
        self.errorTracker = errorTracker
    }
    
    func go(stream: TransformStream) {
        let metadataLine = stream.require(BuildErrorLine.self)
        let color = textColor(for: metadataLine)
        
        var out: WritableStream
        if errorTracker.shouldSkip(metadataLine) {
            out = WriteStream.null
        } else {
            out = stdout
            errorTracker.record(metadataLine)
        }
        
        out.print(type: metadataLine.type, message: metadataLine.message)
        defer {
            let file = metadataLine.path.hasPrefix("/") ? metadataLine.path.beautifyPath : metadataLine.path
            out <<< "    at \(file)" + ":\(metadataLine.lineNumber)"
            out <<< ""
        }
        
        if metadataLine.type == .note && (stream.nextIs(in: stopLines) || !stream.isOpen()) {
            return
        }
        
        let codeLine = stream.require(CodeLine.self)
        let startIndex = codeLine.text.index(where: { $0 != " " }) ?? codeLine.text.startIndex
        out <<< indentation + String(codeLine.text[startIndex...]).lightBlack
        
        while !stream.nextIs(HighlightsLine.self) {
            let otherCode = stream.require(CodeLine.self)
            out <<< indentation + String(otherCode.text[startIndex...]).lightBlack
        }
        
        let highlights = stream.require(HighlightsLine.self)
        out <<< indentation + String(highlights.highlights[startIndex...]).replacingAll(matching: "~", with: "^").applyingColor(color)
        
        while !stream.nextIs(in: stopLines) && stream.isOpen() {
            if stream.match(WhitespaceLine.self) != nil { continue }
            let suggestion = stream.require(SuggestionLine.self)
            out <<< indentation + String(suggestion.text[startIndex...]).applyingColor(color) + "\n"
        }
    }
    
    private func textColor(for line: BuildErrorLine) -> Color {
        switch line.type {
        case .error:
            return .red
        case .warning:
            return .yellow
        case .note:
            return .yellow
        }
    }
    
}


// MARK: -

private class ErrorTracker {
    
    private var past: [BuildErrorLine] = []
    private var skippingCurrent = false
    
    func shouldSkip(_ line: BuildErrorLine) -> Bool {
        if line.type == .note {
            return skippingCurrent
        } else {
            skippingCurrent = past.contains(line)
            return skippingCurrent
        }
    }
    
    func record(_ line: BuildErrorLine) {
        past.append(line)
    }
}

private extension WritableStream {
    
    func print(type: BuildErrorLine.ErrorType, message: String) {
        let prefix: String
        switch type {
        case .error:
            prefix = "\n  ● Error:".red.bold
        case .warning:
            prefix = "\n  ● Warning:".yellow.bold
        case .note:
            prefix = "    Note:".blue
        }
        self <<< "\(prefix) \(message)"
        self <<< ""
    }
    
}
