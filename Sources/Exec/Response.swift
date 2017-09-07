//
//  Response.swift
//  Exec
//
//  Created by Jake Heiser on 9/5/17.
//

import Regex
import CLISpinner

public class ResponseGenerator {
    private let regex: Regex
    private let generate: () -> Response
    
    public init(matcher: StaticString, generate: @escaping () -> Response) {
        self.regex = Regex(matcher)
        self.generate = generate
    }
    
    func matches(_ line: String) -> Bool {
        return regex.matches(line)
    }
    
    func generateResponse(to line: String) -> Response {
        let captures = regex.firstMatch(in: line)?.captures.flatMap { $0 } ?? []
        let response = generate()
        response.go(captures: captures)
        return response
    }
}

public protocol Response: class {
    func go(captures: [String])
    func keepGoing(on line: String) -> Bool
    func stop()
}

public typealias CaptureTranslation = (_ captures: [String]) -> String

public class ReplaceResponse: Response {
    
    private let stream: StdStream
    private let translation: CaptureTranslation
    
    init(stream: StdStream, translation: @escaping CaptureTranslation) {
        self.stream = stream
        self.translation = translation
    }
    
    public func go(captures: [String]) {
        stream.output(translation(captures))
    }
    
    public func keepGoing(on line: String) -> Bool {
        return false
    }
    
    public func stop() {}
    
}

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

public class IgnoreResponse: Response {
    public func go(captures: [String]) {}
    public func keepGoing(on line: String) -> Bool { return false }
    public func stop() {}
}

