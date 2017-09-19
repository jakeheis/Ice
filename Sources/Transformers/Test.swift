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
            t.register(TestsBegunResponse.self, on: .err)
            t.register(XCTestBegunResponse.self, on: .err)
            t.register(TestEndResponse.self, on: .err)
            t.register(TestSuiteResponse.self, on: .err)
            t.ignore("Executed [0-9]+ tests", on: .err)
            t.register(OutputAccumulator.self, on: .out)
        }
    }
    
}

final class OutputAccumulator: SimpleResponse {
    final class Match: Matcher {
        static let regex = Regex("^(.*)$")
        var line: String { return captures[0] }
    }
    
    static var accumulated = ""
    
    init(match: Match) {
        OutputAccumulator.accumulated += match.line
    }
    
    func start() {}
    
    func keepGoing(on line: String) -> Bool {
        let separator = OutputAccumulator.accumulated.isEmpty ? "" : "\n"
        OutputAccumulator.accumulated += separator + line
        return true
    }
    
    func stop() {}
    
}

final class TestsBegunResponse: SimpleResponse {
    final class Match: Matcher {
        enum SuiteMode: String, Capturable {
            case all = "All tests"
            case selected = "Selected tests"
        }
        static let regex = Regex("^Test Suite '(All tests|Selected tests)' started")
        var mode: SuiteMode { return captures[0] }
    }
    
    static var mode: Match.SuiteMode = .all
    
    init(match: Match) {
        TestsBegunResponse.mode = match.mode
    }
    
    func start() {}
    func keepGoing(on line: String) -> Bool { return false }
    func stop() {}
}

final class XCTestBegunResponse: SimpleResponse {
    final class Match: Matcher {
        static let regex = Regex("^Test Suite '(.*)\\.xctest' started")
        var packageName: String { return captures[0] }
    }
    
    static var hasPrinted = false
    
    let match: Match
    
    init(match: Match) {
        self.match = match
    }
    
    func start() {
        if !XCTestBegunResponse.hasPrinted {
            stderr <<< "\n\(match.packageName):\n".bold
            XCTestBegunResponse.hasPrinted = true
        }
        TestCaseResponse.failureCount = 0
    }
    
    func keepGoing(on line: String) -> Bool { return false }
    func stop() {}
}

private final class TestSuiteResponse: SimpleResponse {
    
    final class Match: Matcher {
        static let regex = Regex("^Test Suite '(.*)'")
        var suiteName: String { return captures[0] }
    }
    
    static let doneRegex = Regex("Executed .* tests?")
    
    var name: String
    
    private var failed = false
    private var done = false
    
    var currentTestCase: TestCaseResponse?
    
    init(match: Match) {
        self.name = match.suiteName
    }
    
    func start() {}
    
    func keepGoing(on line: String) -> Bool {
        if done {
            return false
        }
        
        if let currentTestCase = currentTestCase {
            // Continue/end test case
            if currentTestCase.keepGoing(on: line) {
                return true
            } else {
                currentTestCase.stop()
                self.currentTestCase = nil
            }
        }
        
        if let match = TestCaseResponse.Match.findMatch(in: line) {
            // Start test case
            let response = TestCaseResponse(testSuite: self, match: match)
            if !name.contains(".") {
                name = "\(response.match.targetName)." + name
                if TestsBegunResponse.mode == .selected {
                    name += "/\(response.match.caseName)"
                }
                stderr.output(badge(text: "RUNS", color: .blue), terminator: "")
            }
            response.start()
            currentTestCase = response
            return true
        }
        
        if Match.matches(line) {
            // Second to last line
            return true
        }
        
        if TestSuiteResponse.doneRegex.matches(line) {
            done = true
            return true
        }
        
        fatalError("\n\nError: unexpected output: \(line)\n\n")
    }
    
    func markFailed() {
        if !failed {
            stderr <<< OutputTransformer.rewindCharacter + badge(text: "FAIL", color: .red)
            stderr <<< ""
            failed = true
        }
    }
    
    func stop() {
        if failed == false {
            stderr <<< OutputTransformer.rewindCharacter + badge(text: "PASS", color: .green)
        }
    }
    
    func badge(text: String, color: BackgroundColor) -> String {
        return " \(text) ".applyingBackgroundColor(color).black.bold + " " + name.bold
    }
    
}

private final class TestCaseResponse: MatchedResponse {
    
    static var failureCount = 0
    
    final class Match: Matcher {
        enum Status: String, Capturable {
            case started
            case passed
            case failed
        }
        
        static let regex = Regex("^Test Case '-\\[(.*)\\.(.*) (.*)\\]' (started|passed|failed)")
        var targetName: String { return captures[0] }
        var suiteName: String { return captures[1] }
        var caseName: String { return captures[2] }
        var status: Status { return captures[3] }
    }
    
    final class FatalErrorMatch: Matcher {
        static let regex = Regex("^fatal error: (.*)$")
        var message: String { return captures[0] }
    }
    
    let testSuite: TestSuiteResponse
    let match: Match
    
    var status: Match.Status = .started
    var currentAssertionFailure: AssertionResponse?
    var markedAsFailure = false
    
    init(testSuite: TestSuiteResponse, match: Match) {
        self.testSuite = testSuite
        self.match = match
    }
    
    func start() {
        OutputAccumulator.accumulated = ""
    }
    
    func keepGoing(on line: String) -> Bool {
        guard status == .started else {
            return false
        }

        if let currentAssertionFailure = currentAssertionFailure {
            // Continue/end assertion
            if currentAssertionFailure.keepGoing(on: line) {
                return true
            } else {
                currentAssertionFailure.stop()
                self.currentAssertionFailure = nil
            }
        }
        if let match = AssertionResponse.Match.findMatch(in: line) {
            // Start assertion
            if !markedAsFailure {
                testSuite.markFailed()
                stderr <<< " ● \(self.match.caseName)".red.bold
                markedAsFailure = true
                TestCaseResponse.failureCount += 1
            }
            
            let assertionFailure = AssertionResponse(match: match)
            assertionFailure.start()
            self.currentAssertionFailure = assertionFailure
            return true
        }
        
        if let match = Match.findMatch(in: line) {
            status = match.status
            return true
        }
        
        if let match = FatalErrorMatch.findMatch(in: line) {
            testSuite.markFailed()
            stderr <<< "Fatal error: ".red.bold + match.message
            return true
        }
        
        fatalError("\n\nError: unexpected output: `\(line)`\n\n")
    }
    
    func stop() {
        if status == .failed {
            if !OutputAccumulator.accumulated.isEmpty {
                stderr <<< ""
                stderr <<< "\tOutput:"
                stderr <<< OutputAccumulator.accumulated.components(separatedBy: "\n").map({ "\t\($0)" }).joined(separator: "\n").dim
                stderr <<< ""
            }
        }
    }
    
}

final class AssertionResponse: SimpleResponse {
    
    final class Match: Matcher {
        static let regex = Regex("(.*):([0-9]+): error: .* : (.*)$")
        var file: String { return captures[0] }
        var lineNumber: Int { return captures[1] }
        var assertion: String { return captures[2] }
    }
    
    static let newlineReplacement = "______$$$$$$$$"
    
    let file: String
    let lineNumber: Int
    var assertion: String
    
    init(match: Match) {
        self.file = match.file
        self.lineNumber = match.lineNumber
        self.assertion = match.assertion
    }
    
    func start() {}
    
    func keepGoing(on line: String) -> Bool {
        if AssertionResponse.Match.matches(line)
            || TestCaseResponse.FatalErrorMatch.matches(line)
            || TestCaseResponse.Match.matches(line) {
            return false
        }
        
        assertion += AssertionResponse.newlineReplacement + line
        
        return true
    }
    
    func stop() {        
        stderr <<< ""
        
        var foundMatch = false
        for matchType in xctMatches {
            if let match = matchType.findMatch(in: assertion) {
                match.output()
                
                if !match.message.isEmpty {
                    stderr <<< ""
                    let lines = match.message.components(separatedBy: AssertionResponse.newlineReplacement)
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

private final class TestEndResponse: SimpleResponse {
    
    final class Match: Matcher {
        static let regex = Regex("Test Suite '(All tests|Selected tests|.*\\.xctest)' (passed|failed)")
        var suite: String { return captures[0] }
    }
    
    final class CountMatch: Matcher {
        static let regex = Regex("Executed ([0-9]+) tests?, with [0-9]* failures? .* \\(([\\.0-9]+)\\) seconds$")
        var totalCount: Int { return captures[0] }
        var duration: String { return captures[1] }
    }
    
    let stream: OutputByteStream
    var nextLine = true
    
    init(match: Match) {
        if match.suite == "All tests" || match.suite == "Selected tests" {
            stream = OutputTransformer.stderr
        } else {
            stream = NullStream()
        }
    }
    
    func start() {
        stream <<< ""
    }
    
    func keepGoing(on line: String) -> Bool {
        guard nextLine else {
            return false
        }
        nextLine = false
        
        if let match = CountMatch.findMatch(in: line) {
            var parts: [String] = []
            if TestCaseResponse.failureCount > 0 {
                parts.append("\(TestCaseResponse.failureCount) failed".bold.red)
            }
            if TestCaseResponse.failureCount < match.totalCount {
                parts.append("\(match.totalCount - TestCaseResponse.failureCount) passed".bold.green)
            }
            parts.append("\(match.totalCount) total")
            
            stream <<< "Tests:\t".bold.white + parts.joined(separator: ", ")
            stream <<< "Time:\t".bold.white + match.duration + "s"
            stream <<< ""
        }
        
        return true
    }
    
    func stop() {}
    
}

