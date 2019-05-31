//
//  TransformStream.swift
//  Exec
//
//  Created by Jake Heiser on 3/12/18.
//

import Dispatch
import Foundation
import Rainbow
import SwiftCLI

class TransformStream: WritableStream {
    
    let writeHandle: FileHandle
    let processObject: Any
    let encoding: String.Encoding = .utf8

    private let reader: ReadableStream
    private let semaphore = DispatchSemaphore(value: 0)
    private var nextLine: String? = nil
    
    init(transformer: Transformer) {
        let pipe = Pipe()
        writeHandle = pipe.fileHandleForWriting
        processObject = pipe
        reader = ReadStream.for(fileHandle: pipe.fileHandleForReading)
        
        DispatchQueue.global().async {
            while self.isOpen() {
                transformer.go(stream: self)
            }
            self.semaphore.signal()
        }
    }
    
    private func readNextLine() {
        guard nextLine == nil else { return }
        
        nextLine = reader.readLine()
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
        if Logger.level == .verbose {
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
            if Logger.level == .verbose {
                TransformStreamRecord.dump()
            }
            
            WriteStream.stderr <<< ""
            WriteStream.stderr <<< "Internal error: ".bold.red + "failed requirement (\(line), next: '\(nextLine as Any)')"
            WriteStream.stderr <<< ""
            WriteStream.stderr <<< "\(file):\(line)"
            WriteStream.stderr <<< ""
            if Logger.level == .verbose {
                WriteStream.stderr <<< "Please file a new issue with this output"
                WriteStream.stderr <<< "http://github.com/jakeheis/Ice/issues/new"
            } else {
                WriteStream.stderr <<< "Please rerun this command verbosely:"
                let newArgs = [CommandLine.arguments[0], "--verbose"] + Array(CommandLine.arguments.dropFirst())
                WriteStream.stderr <<< "  " + newArgs.joined(separator: " ")
                WriteStream.stderr <<< "then file a new issue with that command's output"
            }
            WriteStream.stderr <<< ""
            
            exit(1)
        }
        
        if Logger.level == .verbose {
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
            if Logger.level == .verbose {
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
    
    func wait() {
        semaphore.wait()
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
        let data = try! JSON.encoder.encode(actions)
        print(String(data: data, encoding: .utf8)!)
    }
    
    static func clear() {
        actionLock.lock()
        defer { actionLock.unlock() }
        actions.removeAll()
    }
    
}
