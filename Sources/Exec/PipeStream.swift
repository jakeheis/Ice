//
//  PipeStream.swift
//  Exec
//
//  Created by Jake Heiser on 3/12/18.
//

import Foundation

public class PipeStream {
    
    let pipe: Pipe
    private var nextLine: String? = nil
    private var unread = ""
    
    init(pipe: Pipe) {
        self.pipe = pipe
    }
    
    private func readNextLine() {
        guard nextLine == nil else { return }
        
        var open = true
        while unread.index(of: "\n") == nil {
            let data = pipe.fileHandleForReading.availableData
            if data.isEmpty {
                open = false
                break
            }
            guard let str = String(data: data, encoding: .utf8) else {
                niceFatalError("output not utf8")
            }
            unread += str
        }
        
        if let index = unread.index(of: "\n") {
            nextLine = String(unread.prefix(upTo: index))
            unread = String(unread.suffix(from: unread.index(after: index)))
        } else if !open {
            nextLine = unread.isEmpty ? nil : unread
            unread = ""
        }
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
                line: PipeStreamRecord.actions.removeLast().line,
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
                    line: nextLine!,
                    type: String(describing: type(of: match))
                ))
            }
            self.nextLine = nil
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
    
    static var actions: [Action] = []
    
    static func record(action: Action) {
        actions.append(action)
    }
    
    static func dump() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try! encoder.encode(actions)
        print(String(data: data, encoding: .utf8)!)
    }
    
}
