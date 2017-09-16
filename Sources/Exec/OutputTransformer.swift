//
//  OutputTransformer.swift
//  CLI
//
//  Created by Jake Heiser on 8/30/17.
//

import Foundation
import Regex

public class OutputTransformer {
    
    let out: Hose
    let error: Hose
    
    let transformQueue: DispatchQueue
    
    private var prefix: String? = nil
    private var suffix: String? = nil
    
    private var outGenerators: [AnyResponseGenerator] = []
    private var errorGenerators: [AnyResponseGenerator] = []
    private var changes: [OutputTransformerChange] = []
    
    private var currentOutResponse: AnyResponse?
    private var currentErrResponse: AnyResponse?
    
    init() {
        self.out = Hose()
        self.error = Hose()
        self.transformQueue = DispatchQueue(label: "com.jakeheis.Ice.OutputTransformer")
        
        self.out.onLine = { [weak self] (line) in
            guard let `self` = self else { return }
            self.transformQueue.async {
                self.readLine(line: line, generators: self.outGenerators, currentResponse: &self.currentOutResponse, stream: .out)
            }
        }
        self.error.onLine = { [weak self] (line) in
            guard let `self` = self else { return }
            self.transformQueue.async {
                self.readLine(line: line, generators: self.errorGenerators, currentResponse: &self.currentErrResponse, stream: .err)
            }
        }
    }
    
    private func readLine(line: String, generators: [AnyResponseGenerator], currentResponse: inout AnyResponse?, stream: StdStream) {
        if !changes.isEmpty {
            var waitingChanges: [OutputTransformerChange] = []
            for change in changes {
                if change.regex.matches(line) {
                    change.change()
                } else {
                    waitingChanges.append(change)
                }
            }
            changes = waitingChanges
        }
        
        if let ongoing = currentResponse {
            if ongoing.keepGoing(on: line) {
                return
            }
            ongoing.stop()
            currentResponse = nil
        }
        for responseGenerator in generators {
            if responseGenerator.matches(line) {
                let response = responseGenerator.generateResponse(to: line)
                response.go()
                currentResponse = response
                return
            }
        }
        stream.output(line)
    }
    
    public func first(_ str: String) {
        self.prefix = str
    }
        
    public func respond(on stream: StdStream, with generator: AnyResponseGenerator) {
        if stream == .out {
            outGenerators.append(generator)
        } else {
            errorGenerators.append(generator)
        }
    }
    
    public func register<T: Matchable, U: SimpleResponse>(_ type: U.Type, on stream: StdStream) where U.Match == T {
        let generation = { (match: T) in
            return U(match: match)
        }
        respond(on: stream, with: ResponseGenerator(matcher: T.regex, generate: generation))
    }
    
    public func replace<T: RegexMatch & Matchable>(_ matcher: T.Type, on stream: StdStream = .out, _ translation: @escaping CaptureTranslation<T>) {
        let generator = ResponseGenerator(matcher: T.regex, generate: {
            ReplaceResponse(match: $0, stream: stream, translation: translation)
        })
        respond(on: stream, with: generator)
    }
    
    public func ignore(_ matcher: StaticString, on stream: StdStream = .out) {
        let generator = ResponseGenerator(matcher: matcher) { (_) in
            return IgnoreResponse()
        }
        respond(on: stream, with: generator)
    }
    
    public func ignore(_ matcher: Regex, on stream: StdStream = .out) {
        let generator = ResponseGenerator(matcher: matcher) { (_) in
            return IgnoreResponse()
        }
        respond(on: stream, with: generator)
    }
    
    public func change(_ matcher: StaticString, on stream: StdStream = .out, change: @escaping () -> ()) {
        changes.append(OutputTransformerChange(regex: Regex(matcher), stream: stream, change: change))
    }
    
    public func last(_ str: String) {
        self.suffix = str
    }
    
    public func attach(_ process: Process) {
        out.attach(.out, process)
        error.attach(.err, process)
    }
    
    func printPrefix() {
        if let prefix = prefix {
            print(prefix, terminator: "")
        }
    }
    
    func printSuffix() {
        let semaphore = DispatchSemaphore(value: 0)
        transformQueue.async {
            semaphore.signal()
        }
        semaphore.wait()

        currentOutResponse?.stop()
        currentOutResponse = nil
        currentErrResponse?.stop()
        currentErrResponse = nil
        
        if let suffix = suffix {
            print(suffix, terminator: "")
        }
    }
    
}

public struct OutputTransformerChange {
    public let regex: Regex
    public let stream: StdStream
    public let change: () -> ()
}
