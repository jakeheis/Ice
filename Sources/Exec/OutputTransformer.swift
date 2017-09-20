//
//  OutputTransformer.swift
//  CLI
//
//  Created by Jake Heiser on 8/30/17.
//

import Foundation
import Regex
import SwiftCLI

public enum StandardStream {
    case out
    case err
}

public class OutputTransformer {
    
    public struct Change {
        public let regex: Regex
        public let change: () -> ()
    }
    
    public static var stdout: OutputByteStream = Term.stdout
    public static var stderr: OutputByteStream = Term.stderr
    public static var rewindCharacter = Term.isTTY ? "\r" : "\n"
    
    let out: Hose
    let error: Hose
    let transformQueue: DispatchQueue
    
    private var prefix: String? = nil
    private var suffix: String? = nil
    
    private var responses: [LineResponse.Type] = []
    private var changes: [Change] = []
    
    private var currentOutResponse: AnyMultiLineResponse?
    private var currentErrResponse: AnyMultiLineResponse?
    
    init() {
        self.out = Hose()
        self.error = Hose()
        self.transformQueue = DispatchQueue(label: "com.jakeheis.Ice.OutputTransformer")
        
        self.out.onLine = { [weak self] (line) in
            guard let `self` = self else { return }
            self.transformQueue.async {
                self.readLine(line: line, currentResponse: &self.currentOutResponse, stream: .out)
            }
        }
        self.error.onLine = { [weak self] (line) in
            guard let `self` = self else { return }
            self.transformQueue.async {
                self.readLine(line: line, currentResponse: &self.currentErrResponse, stream: .err)
            }
        }
    }
    
    private func readLine(line: String, currentResponse: inout AnyMultiLineResponse?, stream: StandardStream) {
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
        
        if let ongoing = currentResponse {
            if ongoing.consume(line: line) {
                return
            }
            ongoing.finish()
            currentResponse = nil
        }
        for response in responses {
            if response.matches(line, stream) {
                currentResponse = response.respond(to: line)
                return
            }
        }
        
        let outputStream = stream == .out ? OutputTransformer.stdout : OutputTransformer.stderr
        outputStream <<< line
    }
    
    public func first(_ str: String) {
        self.prefix = str
    }
    
    public func add<T: LineResponse>(_ type: T.Type) {
        responses.append(type)
    }
    
    public func ignore<T: Line>(_ type: T.Type) {
        add(IgnoreLineResponse<T>.self)
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

        currentOutResponse?.finish()
        currentOutResponse = nil
        currentErrResponse?.finish()
        currentErrResponse = nil
        
        if let suffix = suffix {
            OutputTransformer.stdout.output(suffix, terminator: "")
        }
    }
    
}
