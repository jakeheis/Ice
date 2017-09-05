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

public class OutputTransformer {
    
    public typealias Translation = (_ captures: [String]) -> String
    public typealias SpinnerDone = (_ spinner: Spinner, _ capture: [String]) -> ()
    
    public enum Stream {
        case out
        case err
        
        func output(_ text: String) {
            switch self {
            case .out: print(text)
            case .err: printError(text)
            }
        }
    }
    
    let output: Pipe
    let error: Pipe
    
    private var prefix: String? = nil
    private var suffix: String? = nil
    
    private var responseGenerators: [ResponseGenerator] = []
    private var currentResponse: Response?
    
    init() {
        self.output = Pipe()
        self.error = Pipe()
        
        output.fileHandleForReading.readabilityHandler = readability(stream: .out)
        error.fileHandleForReading.readabilityHandler = readability(stream: .err)
    }
    
    private func readability(stream: Stream) -> (FileHandle) -> () {
        return { (handle) in
            guard let str = String(data:handle.availableData, encoding: .utf8), !str.isEmpty else {
                return
            }
            
            DispatchQueue.main.async {
                var lines = str.components(separatedBy: "\n")
                if let last = lines.last, last.isEmpty {
                    lines.removeLast()
                }
                
                self.currentResponse?.stop()
                self.currentResponse = nil
                for (index, line) in lines.enumerated() {
                    self.respond(stream: stream, line: line, stopImmediately: index < lines.endIndex - 1)
                }
            }
        }
    }
    
    public func first(_ str: String) {
        self.prefix = str
    }
    
    public func replace(_ matcher: StaticString, _ yield: @escaping Translation) {
        responseGenerators.append(ResponseGenerator(matcher: matcher, replace: yield, stream: .out))
    }
    
    public func replaceErr(_ matcher: StaticString, _ yield: @escaping Translation) {
        responseGenerators.append(ResponseGenerator(matcher: matcher, replace: yield, stream: .err))
    }
    
    public func spin(_ matcher: StaticString, _ during: @escaping OutputTransformer.Translation, _ done: @escaping OutputTransformer.SpinnerDone, stream: Stream = .out) {
        responseGenerators.append(ResponseGenerator(matcher: matcher, during: during, after: done, stream: .out))
    }
    
    public func last(_ str: String) {
        self.suffix = str
    }
    
    public func attach(_ process: Process) {
        process.standardOutput = output
        process.standardError = error
    }
    
    private func respond(stream: Stream, line: String, stopImmediately: Bool) {
        for responseGenerator in self.responseGenerators {
            if responseGenerator.matches(stream, line) {
                let response = responseGenerator.respond(line)
                if stopImmediately {
                    response?.stop()
                }
                currentResponse = response
                return
            }
        }
        stream.output(line)
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

private class ResponseGenerator {
    private let regex: Regex
    private let internalResponse: (_ captures: [String]) -> Response?
    private let stream: OutputTransformer.Stream
    
    init(matcher: StaticString, replace: @escaping (_ captures: [String]) -> String, stream: OutputTransformer.Stream) {
        self.regex = Regex(matcher)
        self.internalResponse = { (captures) in
            stream.output(replace(captures))
            return nil
        }
        self.stream = stream
    }
    
    init(matcher: StaticString, during: @escaping (_ captures: [String]) -> String, after: @escaping (_ spinner: Spinner, _ captures: [String]) -> (), stream: OutputTransformer.Stream) {
        self.regex = Regex(matcher)
        self.internalResponse = { (captures) in
            let spinner = Spinner(pattern: .dots, text: during(captures))
            spinner.start()
            return Response(spinner: spinner, after: after, captures: captures)
        }
        self.stream = stream
    }
    
    func matches(_ stream: OutputTransformer.Stream, _ line: String) -> Bool {
        return stream == self.stream && regex.matches(line)
    }
    
    func respond(_ line: String) -> Response? {
        let captures = regex.firstMatch(in: line)?.captures.flatMap { $0 } ?? []
        return internalResponse(captures)
    }
}

private class Response {
    let spinner: Spinner
    let after: (_ spinner: Spinner, _ captures: [String]) -> ()
    let captures: [String]
    
    init(spinner: Spinner, after: @escaping (_ spinner: Spinner, _ captures: [String]) -> (), captures: [String]) {
        self.spinner = spinner
        self.after = after
        self.captures = captures
    }
    
    func stop() {
        after(spinner, captures)
    }
}
