//
//  Response.swift
//  Exec
//
//  Created by Jake Heiser on 9/5/17.
//

import Regex
import SwiftCLI

public protocol AnyResponseGenerator {
    func matches(_ line: String) -> Bool
    func generateResponse(to line: String) -> AnyResponse
}

public class ResponseGenerator<T: Response>: AnyResponseGenerator {
    
    private let regex: Regex
    private let generate: (_ match: T.Match) -> T
    
    public init(matcher: Regex, generate: @escaping (_ match: T.Match) -> T) {
        self.regex = matcher
        self.generate = generate
    }
    
    public init(matcher: StaticString, generate: @escaping (_ match: T.Match) -> T) {
        self.regex = Regex(matcher)
        self.generate = generate
    }
    
    public func matches(_ line: String) -> Bool {
        return regex.matches(line)
    }
    
    public func generateResponse(to line: String) -> AnyResponse {
        guard let result = T.Match.findMatch(in: line) else {
            fatalError("generateResponse should only be called if a match is guaranteed")
        }
        return generate(result)
    }
}

public protocol AnyResponse: class {
    func go()
    func keepGoing(on line: String) -> Bool
    func stop()
}

public protocol Response: AnyResponse {
    associatedtype Match: Matcher
}

public extension Response {
    var stdout: OutputByteStream {
        return OutputTransformer.stdout
    }
    var stderr: OutputByteStream {
        return OutputTransformer.stderr
    }
}

public protocol SimpleResponse: Response {
    init(match: Match)
}

public typealias CaptureTranslation<T: Matcher> = (_ match: T) -> String

public class ReplaceResponse<T: Matcher>: Response {
    
    public typealias Match = T
    public typealias Translation = CaptureTranslation<T>
    
    public let match: T
    private let stream: OutputByteStream
    private let translation: Translation
    
    init(match: T, stream: OutputByteStream, translation: @escaping Translation) {
        self.match = match
        self.stream = stream
        self.translation = translation
    }
    
    public func go() {
        stream <<< translation(match)
    }
    
    public func keepGoing(on line: String) -> Bool {
        return false
    }
    
    public func stop() {}
    
}

public class IgnoreResponse: Response {
    public final class Match: Matcher {
        public static let regex = Regex(".*")
        public init() {}
    }
    public func go() {}
    public func keepGoing(on line: String) -> Bool { return false }
    public func stop() {}
}
