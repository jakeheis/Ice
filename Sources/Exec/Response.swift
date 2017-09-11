//
//  Response.swift
//  Exec
//
//  Created by Jake Heiser on 9/5/17.
//

import Regex
import CLISpinner

public protocol AnyResponseGenerator {
    func matches(_ line: String) -> Bool
    func generateResponse(to line: String) -> AnyResponse
}

public class ResponseGenerator<T: Response>: AnyResponseGenerator {
    
    private let regex: Regex
    private let generate: (_ match: T.Match) -> T
    
    public init(matcher: StaticString, generate: @escaping (_ match: T.Match) -> T) {
        self.regex = Regex(matcher)
        self.generate = generate
    }
    
    public func matches(_ line: String) -> Bool {
        return regex.matches(line)
    }
    
    func match(in line: String) -> T.Match? {
        guard let match = regex.firstMatch(in: line) else {
            return nil
        }
        let captures = Captures(captures: match.captures)
        return T.Match(captures: captures)
    }
    
    public func generateResponse(to line: String) -> AnyResponse {
        guard let result = match(in: line) else {
            fatalError("generateResponse should only be called if a match is guaranteed")
        }
        return generate(result)
    }
}

public protocol AnyResponse: class {
    static var type: RegexMatch.Type { get }
    func go()
    func keepGoing(on line: String) -> Bool
    func stop()
}

public protocol Response: AnyResponse {
    associatedtype Match: RegexMatch
}

extension Response {
    public static var type: RegexMatch.Type { return Match.self }
}

public typealias CaptureTranslation<T: RegexMatch> = (_ match: T) -> String

public class ReplaceResponse<T: RegexMatch>: Response {
    
    public typealias Match = T
    public typealias Translation = CaptureTranslation<T>
    
    public let match: T
    private let stream: StdStream
    private let translation: Translation
    
    init(match: T, stream: StdStream, translation: @escaping Translation) {
        self.match = match
        self.stream = stream
        self.translation = translation
    }
    
    public func go() {
        stream.output(translation(match))
    }
    
    public func keepGoing(on line: String) -> Bool {
        return false
    }
    
    public func stop() {}
    
}
/*
public class SpinnerResponse: Response {
    
    public typealias Completion = (_ spinner: Spinner, _ captures: [String], _ next: String?) -> ()
    
    private let during: CaptureTranslation
    private let after: Completion
    
    private var spinner: Spinner?
    private var captures: [String] = []
    
    private var nextLine: String?
    
    init(during: @escaping CaptureTranslation, after: @escaping Completion) {
        self.during = during
        self.after = after
    }
    
    public func go(captures: [String]) {
        self.captures = captures
        let spinner = Spinner(pattern: .dots, text: during(captures))
        spinner.start()
        self.spinner = spinner
    }
    
    public func keepGoing(on line: String) -> Bool {
        nextLine = line
        return false
    }
    
    public func stop() {
        if let spinner = spinner {
            after(spinner, captures, nextLine)
        }
    }
    
}
*/

public class IgnoreResponse: Response {
    public typealias Match = RegexMatch
    public func go() {}
    public func keepGoing(on line: String) -> Bool { return false }
    public func stop() {}
}

