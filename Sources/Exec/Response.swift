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
}

public extension MultiLineResponse {
    
    public static func matches(_ line: String, _ stream: StandardStream) -> Bool {
        return FirstLine.matches(line, stream)
    }
    
    public static func respond(to line: String) -> AnyMultiLineResponse? {
        guard let line = FirstLine.findMatch(in: line) else {
            fatalError("Ensure matches() is true before calling respond")
        }
        return Self(line: line)
    }
    
    func finish() {
        
    }
    
    func yield<T: MultiLineResponse>(to response: inout T?, line: String) -> Bool {
        guard let currentResponse = response else {
             return false
        }
        if currentResponse.consume(line: line) {
            return true
        } else {
            currentResponse.finish()
            response = nil
            return false
        }
    }
    
}
