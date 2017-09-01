//
//  OutputTransformer.swift
//  CLI
//
//  Created by Jake Heiser on 8/30/17.
//

import Foundation
import Regex
import CLISpinner

class OutputTransformer {
    
    typealias Translation = (_ captures: [String]) -> String
    
    let output: Pipe
    
    var prefix: String? = nil
    var suffix: String? = nil
    private var responses: [OutputResponse] = []
    private var currentResponse: OutputResponse?
    
    init() {
        self.output = Pipe()
        
        output.fileHandleForReading.readabilityHandler = { (handle) in
            guard let str = String(data:handle.availableData, encoding: .utf8) else {
                return
            }
            
            var lines = str.components(separatedBy: "\n")
            if let last = lines.last, last.isEmpty {
                lines.removeLast()
            }
            
            lines.forEach { self.respond(line: $0) }
        }
    }
    
    func first(_ str: String) {
        self.prefix = str
    }
    
    func on(_ matcher: StaticString, yield: @escaping Translation) {
        let regex = Regex(matcher)
        responses.append(TranslateResponse(regex: regex, translation: yield))
    }
    
    func on(_ matcher: StaticString, spinPattern: CLISpinner.Pattern, translation: @escaping OutputTransformer.Translation) {
        let regex = Regex(matcher)
        responses.append(SpinResponse(regex: regex, spinPattern: spinPattern, translation: translation))
    }
    
    func last(_ str: String) {
        self.suffix = str
    }
    
    func attach(_ process: Process) {
        process.standardOutput = output
    }
    
    func respond(line: String) {
        currentResponse?.end()
        for response in self.responses {
            if let match = response.regex.firstMatch(in: line) {
                response.respond(captures: match.captures.flatMap { $0 })
                currentResponse = response
                return
            }
        }
        print(line)
    }
    
}

private protocol OutputResponse: class {
    var regex: Regex { get }
    func respond(captures: [String])
    func end()
}

private class TranslateResponse: OutputResponse {
    
    let regex: Regex
    let translation: OutputTransformer.Translation
    
    init(regex: Regex, translation: @escaping OutputTransformer.Translation) {
        self.regex = regex
        self.translation = translation
    }
    
    func respond(captures: [String]) {
        print(translation(captures))
    }
    
    func end() {}
    
}

private class SpinResponse: OutputResponse {
    
    let regex: Regex
    let spinPattern: CLISpinner.Pattern
    let translation: OutputTransformer.Translation?
    
    private var spinner: Spinner?
    
    init(regex: Regex, spinPattern: CLISpinner.Pattern) {
        self.regex = regex
        self.spinPattern = spinPattern
        self.translation = nil
    }
    
    init(regex: Regex, spinPattern: CLISpinner.Pattern, translation: @escaping OutputTransformer.Translation) {
        self.regex = regex
        self.spinPattern = spinPattern
        self.translation = translation
    }
    
    func respond(captures: [String]) {
        let newSpinner = Spinner(pattern: spinPattern, text: translation?(captures) ?? "")
        newSpinner.start()
        spinner = newSpinner
    }
    
    func end() {
        spinner?.stop()
    }
    
}
