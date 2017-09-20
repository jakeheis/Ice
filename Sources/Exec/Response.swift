//
//  Response.swift
//  Exec
//
//  Created by Jake Heiser on 9/5/17.
//

import SwiftCLI

public protocol LineResponse {}

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

open class IgnoreLineResponse<MatchedLine: Line>: SingleLineResponse {
    public static func respond(to line: MatchedLine) {}
}

public protocol MultiLineResponse: LineResponse {
    associatedtype FirstLine: Line
    
    init(line: FirstLine)
    func consume(line: String) -> Bool
    func finish()
}

public extension MultiLineResponse {
    func finish() {
        
    }
}


public protocol Response: class {
    func start()
    func keepGoing(on line: String) -> Bool
    func stop()
}

public extension Response {
    var stdout: OutputByteStream {
        return OutputTransformer.stdout
    }
    var stderr: OutputByteStream {
        return OutputTransformer.stderr
    }
}

public protocol MatchedResponse: Response {
    associatedtype Match: Matcher
}

public protocol SimpleResponse: MatchedResponse {
    init(match: Match)
}

// MARK: - Built in response types

public class ReplaceResponse<T: Matcher>: MatchedResponse {
    
    public typealias Match = T
    public typealias Translation = (_ match: T) -> String
    
    public let match: T
    private let stream: OutputByteStream
    private let translation: Translation
    
    init(match: T, stream: OutputByteStream, translation: @escaping Translation) {
        self.match = match
        self.stream = stream
        self.translation = translation
    }
    
    public func start() {
        stream <<< translation(match)
    }
    
    public func keepGoing(on line: String) -> Bool {
        return false
    }
    
    public func stop() {}
    
}

public class IgnoreResponse: Response {
    public func start() {}
    public func keepGoing(on line: String) -> Bool { return false }
    public func stop() {}
}
