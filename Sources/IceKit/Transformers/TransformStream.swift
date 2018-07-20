//
//  TransformStream.swift
//  Exec
//
//  Created by Jake Heiser on 3/12/18.
//

import Foundation
import Rainbow
import SwiftCLI

class TransformStream {
    
    let stream: ReadableStream
    
    var nextLine: String? = nil
    
    init(stream: ReadableStream) {
        self.stream = stream
    }
    
    private func readNextLine() {
        guard nextLine == nil else { return }
        
        nextLine = stream.readLine()
    }
    
    func isOpen() -> Bool {
        readNextLine()
        return nextLine != nil
    }
    
    func nextIs<T: Line>(_ t: T.Type) -> Bool {
        return nextIs(t, where: { (_) in true })
    }
    
    func nextIs<T: Line>(_ t: T.Type, where condition: (T) -> Bool) -> Bool {
        readNextLine()
        if let line = nextLine, let match = T.findMatch(in: line), condition(match) {
            return true
        }
        return false
    }
    
    func nextIs(in ts: [Line.Type]) -> Bool {
        readNextLine()
        if let line = nextLine {
            return ts.contains(where: { $0.findMatch(in: line) != nil })
        }
        return false
    }
    
    func consume(file: StaticString = #file, fileLine: UInt = #line) {
        readNextLine()
        if _isDebugAssertConfiguration() {
            TransformStreamRecord.record(action: .init(
                kind: .consumed,
                sourceFile: String(describing: file),
                sourceLineNumber: fileLine,
                line: String(describing: nextLine),
                type: nil
            ))
        }
        nextLine = nil
    }
    
    func require<L: Line>(_ line: L.Type, file: StaticString = #file, fileLine: UInt = #line) -> L {
        guard let match = match(line) else {
            if _isDebugAssertConfiguration() {
                TransformStreamRecord.dump()
                
                WriteStream.stderr <<< ""
                WriteStream.stderr <<< "Fatal error: ".bold.red + "failed requirement (\(line), next: '\(nextLine as Any)')"
                WriteStream.stderr <<< ""
                WriteStream.stderr <<< "\(file):\(line)"
                WriteStream.stderr <<< ""
            }
            exit(1)
        }
        if _isDebugAssertConfiguration() {
            TransformStreamRecord.record(action: .init(
                kind: .required,
                sourceFile: String(describing: file),
                sourceLineNumber: fileLine,
                line: TransformStreamRecord.popLast().line,
                type: String(describing: type(of: match))
            ))
        }
        return match
    }
    
    func match<L: Line>(_ line: L.Type, file: StaticString = #file, fileLine: UInt = #line) -> L? {
        if let match = peek(line) {
            if _isDebugAssertConfiguration() {
                TransformStreamRecord.record(action: .init(
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
    
    func peek<L: Line>(_ line: L.Type) -> L? {
        readNextLine()
        if let nextLine = nextLine, let match = L.findMatch(in: nextLine) {
            return match
        }
        return nil
    }
    
}

class TransformStreamRecord {
    
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
    
    static func clear() {
        actionLock.lock()
        defer { actionLock.unlock() }
        actions.removeAll()
    }
    
}

func niceFatalError(_ message: String, file: StaticString = #file, line: UInt = #line) -> Never {
    WriteStream.stderr <<< "\n\nFatal error:".bold.red + " \(message)\n"
    if _isDebugAssertConfiguration() {
        WriteStream.stderr <<< "\(file):\(line)\n"
    }
    exit(1)
}
