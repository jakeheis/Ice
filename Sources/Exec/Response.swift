//
//  Response.swift
//  Exec
//
//  Created by Jake Heiser on 9/5/17.
//

import SwiftCLI

public protocol LineResponse {
    static func matches(_ line: String, _ stream: StandardStream) -> Bool
    static func respond(to line: String) -> AnyMultiLineResponse?
}

public extension LineResponse {
    static var stdout: OutputByteStream {
        return OutputTransformer.stdout
    }
    static var stderr: OutputByteStream {
        return OutputTransformer.stderr
    }
    var stdout: OutputByteStream {
        return OutputTransformer.stdout
    }
    var stderr: OutputByteStream {
        return OutputTransformer.stderr
    }
}

public protocol SingleLineResponse: LineResponse {
    associatedtype MatchedLine: Line
    static func respond(to line: MatchedLine)
}

extension SingleLineResponse {
    
    public static func matches(_ line: String, _ stream: StandardStream) -> Bool {
        return MatchedLine.matches(line, stream)
    }
    
    public static func respond(to line: String) -> AnyMultiLineResponse? {
        guard let line = MatchedLine.findMatch(in: line) else {
            fatalError("Ensure matches() is true before calling respond")
        }
        respond(to: line)
        return nil
    }
    
}

open class IgnoreLineResponse<MatchedLine: Line>: SingleLineResponse {
    public static func respond(to line: MatchedLine) {}
}

// MARK: -

public protocol AnyMultiLineResponse: LineResponse {
    func consume(line: String) -> Bool
    func finish()
}

public protocol MultiLineResponse: AnyMultiLineResponse {
    associatedtype FirstLine: Line
    
    init(line: FirstLine)
    func consume(input: InputMatcher)
}

public extension MultiLineResponse {
    
    static func matches(_ line: String, _ stream: StandardStream) -> Bool {
        return FirstLine.matches(line, stream)
    }
    
    static func respond(to line: String) -> AnyMultiLineResponse? {
        guard let line = FirstLine.findMatch(in: line) else {
            fatalError("Ensure matches() is true before calling respond")
        }
        return Self(line: line)
    }
    
    func consume(line: String) -> Bool {
        let input = InputMatcher(line: line, stream: Self.FirstLine.stream)
        consume(input: input)
        return input.finish()
    }
    
    func finish() {}
    
}

// MARK: -

public class InputMatcher {
    
    public enum FallbackBehavior {
        case stop
        case print
        case fatalError
    }
    
    private enum Status {
        case consume
        case stop
        case none
    }
    
    private let line: String
    private let stream: StandardStream
    private var status: Status = .none
    
    private var fallbackBehavior: FallbackBehavior = .print
    
    init(line: String, stream: StandardStream) {
        self.line = line
        self.stream = stream
    }
    
    public typealias Filter<T: Line> = (T) -> Bool
    
    public func continueIf<T: Line>(_ type: T.Type, where filter: Filter<T>? = nil) {
        if matchLine(where: filter) != nil {
            status = .consume
        }
    }
    
    public func expect<T: Line>(_ type: T.Type, where filter: Filter<T>? = nil, respond: (T) -> ()) {
        if let line = matchLine(where: filter) {
            respond(line)
            status = .consume
        }
    }
    
    public func stopIf<T: Line>(_ type: T.Type, where filter: Filter<T>? = nil) {
        if matchLine(where: filter) != nil {
            status = .stop
        }
    }
    
    public func yield<T: MultiLineResponse>(to response: inout T?) -> Bool {
        guard let currentResponse = response else {
            return false
        }
        let copy = InputMatcher(line: line, stream: stream)
        currentResponse.consume(input: copy)
        if copy.status == .consume {
            status = .consume
            return true
        } else {
            currentResponse.finish()
            response = nil
            return false
        }
    }
    
    public func stop() {
        if status == .none {
            status = .stop
        }
    }

    private func matchLine<T: Line>(where filter: Filter<T>?) -> T? {
        guard status == .none else {
            return nil
        }
        if let match = T.findMatch(in: line), filter?(match) ?? true {
            return match
        }
        return nil
    }
    
    public func fallback(_ behavior: FallbackBehavior) {
        fallbackBehavior = behavior
    }
    
    func finish(file: StaticString = #file, line: UInt = #line) -> Bool {
        switch status {
        case .consume:
            return true
        case .stop:
            return false
        case .none:
            switch fallbackBehavior {
            case .stop:
                return false
            case .print:
                stream.toOutput() <<< self.line
                return true
            case .fatalError:
                fatalError("Unrecognized line: `\(line)`", file: file, line: line)
            }
        }
    }
    
}
