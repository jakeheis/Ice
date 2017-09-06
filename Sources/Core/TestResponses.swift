//
//  TestResponses.swift
//  Core
//
//  Created by Jake Heiser on 9/5/17.
//

import Exec
import Regex
import Rainbow

class TestSuiteResponse: Response {
    
    static let caseRegex = Regex("^Test Case .* ([^ ]*)\\]' (started|passed|failed)")
    static let doneRegex = Regex("Executed .* tests")
    
    let stream: StdStream
    var suiteName: String?
    
    var done = false
    var failures: [String] = []
    
    init(stream: StdStream) {
        self.stream = stream
    }
    
    func go(captures: [String]) {
        suiteName = captures[0]
        stream.output(badge(text: "RUNS", color: .blue), terminator: "")
    }
    
    func contine(on line: String) -> Bool {
        guard !done else {
            return false
        }
        done = TestSuiteResponse.doneRegex.matches(line)
        if let match = TestSuiteResponse.caseRegex.firstMatch(in: line) {
            if match.captures[1] == "failed" {
                if failures.isEmpty {
                    stream.output("\r" + badge(text: "FAIL", color: .red))
                    stream.output("")
                }
                failures.append(match.captures[0]!)
                print(" ● \(match.captures[0]!)".red.bold)
            }
        }
        return true
    }
    
    func stop() {
        if failures.isEmpty {
            stream.output("\r" + badge(text: "PASS", color: .green))
        } else {
            stream.output("")
        }
    }
    
    func badge(text: String, color: BackgroundColor) -> String {
        return " \(text) ".applyingBackgroundColor(color).black.bold + " " + suiteName!.bold
    }
    
}

class TestEndResponse: Response {
    
    static let countRegex = Regex("Executed ([0-9]+) tests, with ([0-9]*) failures? .* \\(([\\.0-9]+)\\) seconds$")
    
    let stream: StdStream = .err
    var nextLine = true
    
    func go(captures: [String]) {
        stream.output("")
    }
    
    func contine(on line: String) -> Bool {
        guard nextLine else {
            return false
        }
        nextLine = false
        
        if let countMatch = TestEndResponse.countRegex.firstMatch(in: line) {
            if let totalStr = countMatch.captures[0], let totalCount = Int(totalStr),
                let failedStr = countMatch.captures[1], let failedCount = Int(failedStr) {
                
                var parts: [String] = []
                if failedCount > 0 {
                    parts.append("\(failedCount) failed".bold.red)
                }
                if failedCount < totalCount {
                    parts.append("\(totalCount - failedCount) passed".bold.green)
                }
                parts.append("\(totalCount) total")
                
                let output = "Tests:\t".bold.white + parts.joined(separator: ", ")
                stream.output(output)
            }
            if let time = countMatch.captures[2] {
                stream.output("Time:\t".bold.white + time + "s")
            }
        }
        
        return true
    }
    
    func stop() {}
    
}
