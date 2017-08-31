//
//  OutputTransformer.swift
//  CLI
//
//  Created by Jake Heiser on 8/30/17.
//

import Foundation
import Regex

class OutputTransformer {
    
    typealias Translation = (_ captures: [String]) -> String
    
    let output: Pipe
    
    var prefix: String? = nil
    var suffix: String? = nil
    var translations: [(Regex, Translation)] = []
    
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
            
            lines.forEach { self.translate(line: $0) }
        }
    }
    
    func first(_ str: String) {
        self.prefix = str
    }
    
    func on(_ matcher: StaticString, yield: @escaping Translation) {
        let regex = Regex(matcher)
        translations.append((regex, yield))
    }
    
    func last(_ str: String) {
        self.suffix = str
    }
    
    func attach(_ process: Process) {
        process.standardOutput = output
    }
    
    func translate(line: String) {
        for translation in self.translations {
            if let match = translation.0.firstMatch(in: line) {
                print(translation.1(match.captures.flatMap { $0 }))
                return
            }
        }
        print(line)
    }
    
}
