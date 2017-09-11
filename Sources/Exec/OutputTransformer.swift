//
//  OutputTransformer.swift
//  CLI
//
//  Created by Jake Heiser on 8/30/17.
//

import Foundation

public class OutputTransformer {
    
    let out: Hose
    let error: Hose
    
    let transformQueue: DispatchQueue
    
    private var prefix: String? = nil
    private var suffix: String? = nil
    
    private var outGenerators: [AnyResponseGenerator] = []
    private var errorGenerators: [AnyResponseGenerator] = []
    
    private var currentResponse: AnyResponse?
    
    init() {
        self.out = Hose()
        self.error = Hose()
        self.transformQueue = DispatchQueue(label: "com.jakeheis.Ice.OutputTransformer")
        
        self.out.onLine = { [weak self] in self?.readLine(stream: .out, line: $0) }
        self.error.onLine = { [weak self] in self?.readLine(stream: .err, line: $0) }
    }
    
    private func readLine(stream: StdStream, line: String) {
        self.transformQueue.async {
            if let currentResponse = self.currentResponse {
                if currentResponse.keepGoing(on: line) {
                    return
                }
                currentResponse.stop()
                self.currentResponse = nil
            }
            let generators = stream == .out ? self.outGenerators : self.errorGenerators
            for responseGenerator in generators {
                if responseGenerator.matches(line) {
                    let response = responseGenerator.generateResponse(to: line)
                    response.go()
                    self.currentResponse = response
                    return
                }
            }
            stream.output(line)
        }
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
        
        currentResponse?.stop()
        currentResponse = nil
        
        if let suffix = suffix {
            print(suffix, terminator: "")
        }
    }
    
}
