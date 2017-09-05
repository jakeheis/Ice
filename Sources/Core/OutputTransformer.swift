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

public class OutputTransformer {
    
    public typealias Translation = (_ captures: [String]) -> String
    public typealias SpinnerDone = (_ spinner: Spinner, _ capture: [String]) -> ()
    
    let output: Pipe
    
    private var prefix: String? = nil
    private var suffix: String? = nil
    
    private var responseGenerators: [ResponseGenerator] = []
    private var currentResponse: Response?
    
    init() {
        self.output = Pipe()
        
        output.fileHandleForReading.readabilityHandler = { (handle) in
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
                    self.respond(line: line, stopImmediately: index < lines.endIndex - 1)
                }
            }
        }
    }
    
    public func first(_ str: String) {
        self.prefix = str
    }
    
    public func replace(_ matcher: StaticString, _ yield: @escaping Translation) {
        responseGenerators.append(ResponseGenerator(matcher: matcher, replace: yield))
    }
    
    public func spin(_ matcher: StaticString, _ during: @escaping OutputTransformer.Translation, _ done: @escaping OutputTransformer.SpinnerDone) {
        responseGenerators.append(ResponseGenerator(matcher: matcher, during: during, after: done))
    }
    
    public func last(_ str: String) {
        self.suffix = str
    }
    
    public func attach(_ process: Process) {
        process.standardOutput = output
    }
    
    private func respond(line: String, stopImmediately: Bool) {
        for responseGenerator in self.responseGenerators {
            if let match = responseGenerator.regex.firstMatch(in: line) {
                let response = responseGenerator.respond(captures: match.captures.flatMap { $0 })
                if stopImmediately {
                    response?.stop()
                }
                currentResponse = response
                return
            }
        }
        print(line)
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
    let regex: Regex
    
    let internalResponse: (_ captures: [String]) -> Response?
    
    init(matcher: StaticString, replace: @escaping (_ captures: [String]) -> String) {
        self.regex = Regex(matcher)
        self.internalResponse = { (captures) in
            print(replace(captures))
            return nil
        }
    }
    
    init(matcher: StaticString, during: @escaping (_ captures: [String]) -> String, after: @escaping (_ spinner: Spinner, _ captures: [String]) -> ()) {
        self.regex = Regex(matcher)
        self.internalResponse = { (captures) in
            let spinner = Spinner(pattern: .dots, text: during(captures))
            spinner.start()
            return Response(spinner: spinner, after: after, captures: captures)
        }
    }
    
    func respond(captures: [String]) -> Response? {
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
