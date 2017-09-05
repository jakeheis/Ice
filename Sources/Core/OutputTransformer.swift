//
//  OutputTransformer.swift
//  CLI
//
//  Created by Jake Heiser on 8/30/17.
//

import Foundation
import Regex
import CLISpinner
import Dispatch
import SwiftCLI

class Hose {
    
    private let pipe: Pipe
    var onLine: ((_ line: String) -> ())?
    
    init() {
        self.pipe = Pipe()
        self.pipe.fileHandleForReading.readabilityHandler = { (handle) in
            guard let str = String(data: handle.availableData, encoding: .utf8), !str.isEmpty else {
                return
            }
            
            DispatchQueue.main.async {
                var lines = str.components(separatedBy: "\n")
                if let last = lines.last, last.isEmpty {
                    lines.removeLast()
                }
                for line in lines {
                    self.onLine?(line)
                }
            }
        }
    }
    
    func attachStdout(_ process: Process) {
        process.standardOutput = pipe
    }
    
    func attachStderr(_ process: Process) {
        process.standardError = pipe
    }
    
}

public enum Stream {
    case out
    case err
    
    func output(_ text: String, terminator: String = "\n") {
        switch self {
        case .out: print(text, terminator: terminator)
        case .err: printError(text, terminator: terminator)
        }
    }
}

public class OutputTransformer {
    
    public typealias SpinnerDone = (_ spinner: Spinner, _ capture: [String]) -> ()
    
    let out: Hose
    let error: Hose
    
    private var prefix: String? = nil
    private var suffix: String? = nil
    
    private var outGenerators: [ResponseGenerator] = []
    private var errorGenerators: [ResponseGenerator] = []
    
    private var currentResponse: Response?
    
    init() {
        self.out = Hose()
        self.error = Hose()
        
        self.out.onLine = { [weak self] in self?.readLine(stream: .out, line: $0) }
        self.error.onLine = { [weak self] in self?.readLine(stream: .err, line: $0) }
    }
    
    private func readLine(stream: Stream, line: String) {
        if let currentResponse = currentResponse {
            if currentResponse.contine(on: line) {
                return
            }
            currentResponse.stop()
        }
        let generators = stream == .out ? outGenerators : errorGenerators
        for responseGenerator in generators {
            if responseGenerator.matches(line) {
                currentResponse = responseGenerator.generateResponse(to: line)
                return
            }
        }
        stream.output(line)
    }
    
    public func first(_ str: String) {
        self.prefix = str
    }
    
    public func respond(on stream: Stream, with generator: ResponseGenerator) {
        if stream == .out {
            outGenerators.append(generator)
        } else {
            errorGenerators.append(generator)
        }
    }
    
    public func replace(_ matcher: StaticString, on stream: Stream = .out, _ translation: @escaping CaptureTranslation) {
        let generator = ResponseGenerator(matcher: matcher, generate: {
            return ReplaceResponse(stream: stream, translation: translation)
        })
        respond(on: stream, with: generator)
    }
    
    public func spin(_ matcher: StaticString, _ during: @escaping CaptureTranslation, _ done: @escaping SpinnerResponse.Completion) {
        let generator = ResponseGenerator(matcher: matcher, generate: {
            return SpinnerResponse(during: during, after: done)
        })
        respond(on: .out, with: generator)
    }
    
    public func ignore(_ matcher: StaticString, on stream: Stream = .out) {
        let generator = ResponseGenerator(matcher: matcher) {
            return IgnoreResponse()
        }
        respond(on: stream, with: generator)
    }
    
    public func last(_ str: String) {
        self.suffix = str
    }
    
    public func attach(_ process: Process) {
        out.attachStdout(process)
        error.attachStderr(process)
    }
    
    func printPrefix() {
        if let prefix = prefix {
            print(prefix, terminator: "")
        }
    }
    
    func printSuffix() {
        currentResponse?.stop()
        currentResponse = nil
        
        if let suffix = suffix {
            print(suffix, terminator: "")
        }
    }
    
}

public class ResponseGenerator {
    private let regex: Regex
    private let generate: () -> Response
    
    init(matcher: StaticString, generate: @escaping () -> Response) {
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
    func contine(on line: String) -> Bool
    func stop()
}

public typealias CaptureTranslation = (_ captures: [String]) -> String

public class ReplaceResponse: Response {
    
    private let stream: Stream
    private let translation: CaptureTranslation
    
    init(stream: Stream, translation: @escaping CaptureTranslation) {
        self.stream = stream
        self.translation = translation
    }
    
    public func go(captures: [String]) {
        stream.output(translation(captures))
    }
    
    public func contine(on line: String) -> Bool {
        return false
    }
    
    public func stop() {}
    
}

public class SpinnerResponse: Response {
    
    public typealias Completion = (_ spinner: Spinner, _ captures: [String]) -> ()

    private let during: CaptureTranslation
    private let after: Completion
    
    private var spinner: Spinner?
    private var captures: [String] = []
    
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
    
    public func contine(on line: String) -> Bool {
        return false
    }

    public func stop() {
        if let spinner = spinner {
            after(spinner, captures)
        }
    }
    
}

public class IgnoreResponse: Response {
    public func go(captures: [String]) {}
    public func contine(on line: String) -> Bool { return false }
    public func stop() {}
}
