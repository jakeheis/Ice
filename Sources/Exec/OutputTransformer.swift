//
//  OutputTransformer.swift
//  CLI
//
//  Created by Jake Heiser on 8/30/17.
//

import Foundation
import Regex
import SwiftCLI

public class OutputTransformer {
    
    public enum StandardStream {
        case out
        case err
    }
    
    public struct Change {
        public let regex: Regex
        public let change: () -> ()
    }
    
    public static var stdout: OutputByteStream = Term.stdout
    public static var stderr: OutputByteStream = Term.stderr
    
    let out: Hose
    let error: Hose
    let transformQueue: DispatchQueue
    
    private var prefix: String? = nil
    private var suffix: String? = nil
    
    private var outGenerators: [ResponseGenerator] = []
    private var errorGenerators: [ResponseGenerator] = []
    private var changes: [Change] = []
    
    private var currentOutResponse: Response?
    private var currentErrResponse: Response?
    
    init() {
        self.out = Hose()
        self.error = Hose()
        self.transformQueue = DispatchQueue(label: "com.jakeheis.Ice.OutputTransformer")
        
        self.out.onLine = { [weak self] (line) in
            guard let `self` = self else { return }
            self.transformQueue.async {
                self.readLine(line: line, generatorsPath: \.outGenerators, currentResponse: &self.currentOutResponse, stream: OutputTransformer.stdout)
            }
        }
        self.error.onLine = { [weak self] (line) in
            guard let `self` = self else { return }
            self.transformQueue.async {
                self.readLine(line: line, generatorsPath: \.errorGenerators, currentResponse: &self.currentErrResponse, stream: OutputTransformer.stderr)
            }
        }
    }
    
    private func readLine(line: String, generatorsPath: KeyPath<OutputTransformer, [ResponseGenerator]>, currentResponse: inout Response?, stream: OutputByteStream) {
        if !changes.isEmpty {
            var waitingChanges: [Change] = []
            for change in changes {
                if change.regex.matches(line) {
                    change.change()
                } else {
                    waitingChanges.append(change)
                }
            }
            changes = waitingChanges
        }
        
        let generators = self[keyPath: generatorsPath]
        
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
                response.start()
                currentResponse = response
                return
            }
        }
        stream <<< line
    }
    
    public func first(_ str: String) {
        self.prefix = str
    }
        
    public func respond(on stream: StandardStream, with generator: ResponseGenerator) {
        if stream == .out {
            outGenerators.append(generator)
        } else {
            errorGenerators.append(generator)
        }
    }
    
    public func register<T: SimpleResponse>(_ type: T.Type, on stream: StandardStream) {
        respond(on: stream, with: ResponseGenerator(type))
    }
    
    public func replace<T: Matcher>(_ matcher: T.Type, on stdStream: StandardStream, _ translation: @escaping ReplaceResponse<T>.Translation) {
        let stream = stdStream == .out ? OutputTransformer.stdout : OutputTransformer.stderr
        let generator = ResponseGenerator(ReplaceResponse<T>.self, generate: { (match) in
            return ReplaceResponse(match: match, stream: stream, translation: translation)
        })
        respond(on: stdStream, with: generator)
    }
    
    public func ignore(_ regex: StaticString, on stream: StandardStream) {
        ignore(Regex(regex), on: stream)
    }
    
    public func ignore(_ regex: Regex, on stream: StandardStream) {
        let generator = ResponseGenerator(regex: regex) { (_) in
            return IgnoreResponse()
        }
        respond(on: stream, with: generator)
    }
    
    public func after(_ matcher: StaticString, change: @escaping () -> ()) {
        changes.append(Change(regex: Regex(matcher), change: change))
    }
    
    public func last(_ str: String) {
        self.suffix = str
    }
    
    public func start(with process: Process?) {
        if let process = process {
            process.attachStdout(to: out)
            process.attachStderr(to: error)
        }
        
        if let prefix = prefix {
            OutputTransformer.stdout.output(prefix, terminator: "")
        }
    }
    
    public func finish() {
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
            OutputTransformer.stdout.output(suffix, terminator: "")
        }
    }
    
}
