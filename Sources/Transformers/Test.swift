//
//  Test.swift
//  Transformers
//
//  Created by Jake Heiser on 9/12/17.
//

import Exec
import Regex
import Rainbow
import SwiftCLI

public extension Transformers {
    
    static func test(t: OutputTransformer) {
        build(t: t)
        t.after("^Test Suite") {
            t.add(AllTestsStartResponse.self)
            t.add(PackageTestsStartResponse.self)
            t.add(TestEndResponse.self)
            t.add(TestSuiteResponse.self)
            t.ignore(TestCountLine.self)
            t.add(OutResponse.self)
        }
    }
    
}

final class OutResponse: SingleLineResponse {
    static var accumulated = ""
    static func respond(to line: AnyOutLine) {
        accumulated += (accumulated.isEmpty ? "" : "\n") + line.text
    }
}

final class AllTestsStartResponse: SingleLineResponse {
    static var mode: AllTestsStartLine.SuiteMode = .all
    static func respond(to line: AllTestsStartLine) {
        mode = line.mode
    }
}

final class PackageTestsStartResponse: SingleLineResponse {
    static var hasPrinted = false
    static func respond(to line: PackageTestsStartMatch) {
        if !hasPrinted {
            stderr <<< "\n\(line.packageName):\n".bold
            hasPrinted = true
        }
        TestCaseResponse.failureCount = 0
    }
}

final class TestSuiteResponse: MultiLineResponse {
    
    var name: String
    
    private var failed = false
    private var done = false
    
    private var currentTestCase: TestCaseResponse?
    
    init(line: TestSuiteLine) {
        name = line.suiteName
    }
    
    func consume(line: String) -> Bool {
        if done {
            return false
        }
        
        if yield(to: &currentTestCase, line: line) {
            return true
        }
        
        if let line = TestCaseLine.findMatch(in: line) {
            // Start test case
            let response = TestCaseResponse(line: line)
            response.testSuite = self
            if !name.contains(".") {
                name = "\(response.line.targetName)." + name
                if AllTestsStartResponse.mode == .selected {
                    name += "/\(response.line.caseName)"
                }
                stderr.output(badge(text: "RUNS", color: .blue), terminator: "")
                // TODO: flush pipe
            }
            currentTestCase = response
            return true
        }
        
        if TestSuiteLine.matches(line) {
            // Second to last line
            return true
        }
        
        if TestCountLine.matches(line) {
            done = true
            return true
        }
        
        fatalError("\n\nError: unexpected output: \(line)\n\n")
    }
    
    func finish() {
        if failed == false {
            stderr <<< OutputTransformer.rewindCharacter + badge(text: "PASS", color: .green)
        }
    }
    
    func markFailed() {
        if !failed {
            stderr <<< OutputTransformer.rewindCharacter + badge(text: "FAIL", color: .red)
            stderr <<< ""
            failed = true
        }
    }
    
    func badge(text: String, color: BackgroundColor) -> String {
        return " \(text) ".applyingBackgroundColor(color).black.bold + " " + name.bold
    }
    
}

final class TestCaseResponse: MultiLineResponse {
    
    static var failureCount = 0
    
    let line: TestCaseLine
    var status: TestCaseLine.Status = .started
    weak var testSuite: TestSuiteResponse?
    var currentAssertionFailure: AssertionFailureResponse?
    var markedAsFailure = false
    
    init(line: TestCaseLine) {
        self.line = line
        OutResponse.accumulated = ""
    }
    
    func consume(line: String) -> Bool {
        guard status == .started else {
            return false
        }
        
        if yield(to: &currentAssertionFailure, line: line) {
            return true
        }

        if let match = AssertionFailureResponse.FirstLine.findMatch(in: line) {
            // Start assertion
            if !markedAsFailure {
                testSuite?.markFailed()
                stderr <<< " ● \(self.line.caseName)".red.bold
                markedAsFailure = true
                TestCaseResponse.failureCount += 1
            }
            
            self.currentAssertionFailure = AssertionFailureResponse(line: match)
            return true
        }
        
        if let match = TestCaseLine.findMatch(in: line) {
            status = match.status
            return true
        }
        
        if let match = FatalErrorLine.findMatch(in: line) {
            testSuite?.markFailed()
            stderr <<< "Fatal error: ".red.bold + match.message
            return true
        }
        
        fatalError("\n\nError: unexpected output: `\(line)`\n\n")
    }
    
    func stop() {
        if status == .failed {
            if !OutResponse.accumulated.isEmpty {
                stderr <<< ""
                stderr <<< "\tOutput:"
                stderr <<< OutResponse.accumulated.components(separatedBy: "\n").map({ "\t\($0)" }).joined(separator: "\n").dim
                stderr <<< ""
            }
        }
    }
    
}

final class AssertionFailureResponse: MultiLineResponse {
    
    static let newlineReplacement = "______$$$$$$$$"
    
    let file: String
    let lineNumber: Int
    var assertion: String
    
    init(line: AssertionFailureLine) {
        self.file = line.file
        self.lineNumber = line.lineNumber
        self.assertion = line.assertion
    }
    
    func consume(line: String) -> Bool {
        if AssertionFailureLine.matches(line)
            || FatalErrorLine.matches(line)
            || TestCaseLine.matches(line) {
            return false
        }
        assertion += AssertionFailureResponse.newlineReplacement + line
        return true
    }
    
    func finish() {
        stderr <<< ""
        
        var foundMatch = false
        for matchType in xctMatches {
            if let match = matchType.findMatch(in: assertion) {
                match.output()
                
                if !match.message.isEmpty {
                    stderr <<< ""
                    let lines = match.message.components(separatedBy: AssertionFailureResponse.newlineReplacement)
                    var message = lines[0]
                    if lines.count > 1 {
                        message += "\n" + lines.dropFirst().map({ "\t\($0)" }).joined(separator: "\n")
                    }
                    stderr <<< "\tNote: \(message)"
                }
                
                foundMatch = true
                break
            }
        }
        
        if !foundMatch {
            stderr <<< "\tError: ".red + assertion
        }
        
        let fileLocation = file.beautifyPath
        stderr <<< ""
        stderr <<< "\tat \(fileLocation):\(lineNumber)".dim
        stderr <<< ""
    }
    
}

final class TestEndResponse: MultiLineResponse {
    
    let stream: OutputByteStream
    var shouldConsumeNextLine = true
    
    init(line: AllTestsEndLine) {
        if line.suite == "All tests" || line.suite == "Selected tests" {
            stream = OutputTransformer.stderr
        } else {
            stream = NullStream()
        }
        
        stream <<< ""
    }
    
    func consume(line: String) -> Bool {
        if !shouldConsumeNextLine {
            return false
        }
        shouldConsumeNextLine = false
        if let line = TestCountLine.findMatch(in: line) {
            var parts: [String] = []
            if TestCaseResponse.failureCount > 0 {
                parts.append("\(TestCaseResponse.failureCount) failed".bold.red)
            }
            if TestCaseResponse.failureCount < line.totalCount {
                parts.append("\(line.totalCount - TestCaseResponse.failureCount) passed".bold.green)
            }
            parts.append("\(line.totalCount) total")
            
            stream <<< "Tests:\t".bold.white + parts.joined(separator: ", ")
            stream <<< "Time:\t".bold.white + line.duration + "s"
            stream <<< ""
            return true
        }
        fatalError("Unrecognized line: `\(line)`")
    }
    
}
