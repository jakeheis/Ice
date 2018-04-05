//
//  PipeStream.swift
//  Exec
//
//  Created by Jake Heiser on 3/12/18.
//

import Foundation
import Rainbow
import SwiftCLI

public class TransformStream {
    
    let stream: ReadableStream
    
    var nextLine: String? = nil
    
    init(stream: ReadableStream) {
        self.stream = stream
    }
    
    private func readNextLine() {
        guard nextLine == nil else { return }
        
        nextLine = stream.readLine()
    }
    
    public func isOpen() -> Bool {
        readNextLine()
        return nextLine != nil
    }
    
    public func nextIs<T: Line>(_ t: T.Type) -> Bool {
        return nextIs(t, where: { (_) in true })
    }
    
    public func nextIs<T: Line>(_ t: T.Type, where condition: (T) -> Bool) -> Bool {
        readNextLine()
        if let line = nextLine, let match = T.findMatch(in: line), condition(match) {
            return true
        }
        return false
    }
    
    public func nextIs(in ts: [Line.Type]) -> Bool {
        readNextLine()
        if let line = nextLine {
            return ts.contains(where: { $0.findMatch(in: line) != nil })
        }
        return false
    }
    
    public func consume(file: StaticString = #file, fileLine: UInt = #line) {
        readNextLine()
        if _isDebugAssertConfiguration() {
            PipeStreamRecord.record(action: .init(
                kind: .consumed,
                sourceFile: String(describing: file),
                sourceLineNumber: fileLine,
                line: String(describing: nextLine),
                type: nil
            ))
        }
        nextLine = nil
    }
    
    public func require<L: Line>(_ line: L.Type, file: StaticString = #file, fileLine: UInt = #line) -> L {
        guard let match = match(line) else {
            if _isDebugAssertConfiguration() {
                PipeStreamRecord.dump()
            }
            niceFatalError("failed requirement (\(line), next: '\(nextLine as Any)')", file: file, line: fileLine)
        }
        if _isDebugAssertConfiguration() {
            PipeStreamRecord.record(action: .init(
                kind: .required,
                sourceFile: String(describing: file),
                sourceLineNumber: fileLine,
                line: PipeStreamRecord.popLast().line,
                type: String(describing: type(of: match))
            ))
        }
        return match
    }
    
    public func match<L: Line>(_ line: L.Type, file: StaticString = #file, fileLine: UInt = #line) -> L? {
        if let match = peek(line) {
            if _isDebugAssertConfiguration() {
                PipeStreamRecord.record(action: .init(
                    kind: .matched,
                    sourceFile: String(describing: file),
                    sourceLineNumber: fileLine,
                    line: nextLine ?? "(nil)",
                    type: String(describing: type(of: match))
                ))
            }
            nextLine = nil
            return match
        }
        return nil
    }
    
    public func peek<L: Line>(_ line: L.Type) -> L? {
        readNextLine()
        if let nextLine = nextLine, let match = L.findMatch(in: nextLine) {
            return match
        }
        return nil
    }
    
}

class PipeStreamRecord {
    
    struct Action: Encodable {
        enum Kind: String, Encodable {
            case required
            case matched
            case consumed
        }
        let kind: Kind
        let sourceFile: String
        let sourceLineNumber: UInt
        let line: String
        let type: String?
    }
    
    private static var actions: [Action] = []
    private static var actionLock = NSLock()
    
    static func record(action: Action) {
        actionLock.lock()
        actions.append(action)
        actionLock.unlock()
    }
    
    static func popLast() -> Action {
        actionLock.lock()
        defer { actionLock.unlock() }
        return actions.removeLast()
    }
    
    static func dump() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try! encoder.encode(actions)
        print(String(data: data, encoding: .utf8)!)
    }
    
}

public func niceFatalError(_ message: String, file: StaticString = #file, line: UInt = #line) -> Never {
    WriteStream.stderr <<< "\n\nFatal error:".bold.red + " \(message)\n"
    if _isDebugAssertConfiguration() {
        printError("\(file):\(line)\n")
    }
    exit(1)
}
