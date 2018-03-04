//
//  Test.swift
//  Transformers
//
//  Created by Jake Heiser on 9/12/17.
//

import Foundation
import Exec
import Regex
import Rainbow
import SwiftCLI

public extension Transformers {
    
    static func test(t: OutputTransformer) {
        build(t: t)
        t.after("^Test Suite") {
            t.clearResponses()
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
    
    func consume(input: InputMatcher) {
        if done {
            input.stop()
            return
        }
        
        if input.yield(to: &currentTestCase) {
            return
        }
        
        input.expect(TestCaseLine.self) { (line) in
            let response = TestCaseResponse(line: line)
            response.testSuite = self
            currentTestCase = response
            
            if !name.contains(".") {
                name = "\(response.line.targetName)." + name
                if AllTestsStartResponse.mode == .selected {
                    name += "/\(response.line.caseName)"
                }
                stderr.output(badge(text: "RUNS", color: .blue), terminator: "")
                fflush(Foundation.stderr)
            }
        }
        
        input.continueIf(TestSuiteLine.self) // Second to last line
        input.expect(TestCountLine.self) { (line) in
            done = true
        }
        
        input.fallback(.ignore)
    }
    
    func finish() {
        if !failed {
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
    
    func consume(input: InputMatcher) {
        guard status == .started else {
            input.stop()
            return
        }
        
        if input.yield(to: &currentAssertionFailure) {
            return
        }
        
        input.expect(AssertionFailureLine.self) { (line) in
            currentAssertionFailure = AssertionFailureResponse(line: line)
            if !markedAsFailure {
                testSuite?.markFailed()
                stderr <<< " ● \(self.line.caseName)".red.bold
                markedAsFailure = true
                TestCaseResponse.failureCount += 1
            }
        }
        input.expect(TestCaseLine.self) { (line) in
            status = line.status
        }
        input.expect(FatalErrorLine.self) { (line) in
            testSuite?.markFailed()
            stderr <<< "Fatal error: ".red.bold + line.message
        }
        
        input.fallback(.ignore)
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
    
    func consume(input: InputMatcher) {
        input.stopIf(AssertionFailureLine.self)
        input.stopIf(FatalErrorLine.self)
        input.stopIf(TestCaseLine.self)
        
        input.expect(AnyErrLine.self) { (line) in
            assertion += AssertionFailureResponse.newlineReplacement + line.text
        }
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
    
    init(line: AllTestsEndLine) {
        if line.suite == "All tests" || line.suite == "Selected tests" {
            stream = OutputTransformer.stderr
        } else {
            stream = NullStream()
        }
        
        stream <<< ""
    }
    
    func consume(input: InputMatcher) {
        input.expect(TestCountLine.self) { (line) in
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
        }
        input.fallback(.stop)
    }
    
}
