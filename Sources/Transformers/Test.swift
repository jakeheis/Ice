//
//  Test.swift
//  Transformers
//
//  Created by Jake Heiser on 9/12/17.
//

import Exec
import Regex
import Rainbow

public extension Transformers {
    
    static func test(t: OutputTransformer) {
        build(t: t)
        t.ignore("^Test Suite 'All tests' started", on: .err)
        t.replace(PackageTestsBegunMatch.self, on: .err) { "\n\($0.packageName):\n".bold }
        t.ignore("^Test Suite '(.*)\\.xctest'", on: .err)
        t.register(TestEndResponse.self, on: .err)
        t.register(TestSuiteResponse.self, on: .err)
        t.ignore("Executed [0-9]+ tests", on: .err)
        t.ignore(".*", on: .out)
        t.last("\n")
    }
    
}

private class PackageTestsBegunMatch: RegexMatch, Matchable {
    static let regex = Regex("^Test Suite '(.*)\\.xctest' started")
    var packageName: String { return captures[0] }
}

private final class TestSuiteResponse: SimpleResponse {
    
    class Match: RegexMatch, Matchable {
        static let regex = Regex("^Test Suite '(.*)'")
        var suiteName: String { return captures[0] }
    }
    
    class CaseMatch: RegexMatch, Matchable {
        enum Status: String, Capturable {
            case started
            case passed
            case failed
        }
        
        static let regex = Regex("^Test Case .* ([^ ]*)\\]' (started|passed|failed)")
        var caseName: String { return captures[0] }
        var status: Status { return captures[1] }
    }
    
    class XCTFailureMatch: RegexMatch, Matchable {
        static let regex = Regex("(.*):([0-9]+): error: .* : (.*)( - (.*))?$")
        var file: String { return captures[0] }
        var lineNumber: Int { return captures[1] }
        var assertion: String { return captures[2] }
        var message: String? { return captures[3] }
    }
    
    static let doneRegex = Regex("Executed .* tests")
    
    class RemainingMatch: RegexMatch, Matchable {
        static let regex = Regex("(.*) - (.*)$")
        var assertion: String { return captures[0] }
        var message: String { return captures[1] }
    }
    
    struct AssertionFailure {
        let file: String
        let lineNumber: Int
        var assertion: String
        var message: String?
    }
    
    let suiteName: String
    let stream: StdStream = .err
    
    var done = false
    var failures: [String] = []
    var currentAssertionFailures: [AssertionFailure] = []
    
    init(match: Match) {
        self.suiteName = match.suiteName
    }
    
    func go() {
        stream.output(badge(text: "RUNS", color: .blue), terminator: "")
    }
    
    func keepGoing(on line: String) -> Bool {
        guard !done else {
            return false
        }
        if TestSuiteResponse.doneRegex.matches(line) {
            done = true
        } else if let xctFailure = XCTFailureMatch.match(line) {
            currentAssertionFailures.append(AssertionFailure(
                file: xctFailure.file,
                lineNumber: xctFailure.lineNumber,
                assertion: xctFailure.assertion.trimmed,
                message: xctFailure.message?.trimmed
            ))
        } else if let match = CaseMatch.match(line) {
            if match.status == .failed {
                if failures.isEmpty {
                    stream.output("\r" + badge(text: "FAIL", color: .red))
                    stream.output("")
                }
                failures.append(match.caseName)
                stream.output(" ● \(match.caseName)".red.bold)
                
                for failure in currentAssertionFailures {
                    printAssertionFailure(failure)
                }
            }
            currentAssertionFailures = []
        } else if let match = RemainingMatch.match(line) {
            if var failure = currentAssertionFailures.last {
                failure.assertion =  failure.assertion + "\n" + match.assertion
                failure.message = match.message
                currentAssertionFailures[currentAssertionFailures.count - 1] = failure
            }
        } else {
            if var failure = currentAssertionFailures.last {
                failure.assertion =  failure.assertion + "\n"  + line
                currentAssertionFailures[currentAssertionFailures.count - 1] = failure
            }
        }
        return true
    }
    
    func printAssertionFailure(_ failure: AssertionFailure) {
        stream.output()
        let fileLocation = failure.file.trimmingCurrentDirectory
        
        let lineBreak = "________"
        let totalMessage = failure.assertion.replacingOccurrences(of: "\n", with: lineBreak)
        if let equalsMatch = Regex("\\(\"(.*)\"\\) is not equal to \\(\"(.*)\"\\)").firstMatch(in: totalMessage),
            let received = equalsMatch.captures[0], let expected = equalsMatch.captures[1] {
            printWrongValue(
                expected: expected.replacingOccurrences(of: lineBreak, with: "\n"),
                received: received.replacingOccurrences(of: lineBreak, with: "\n")
            )
        } else if let nilMatch = Regex("XCTAssertNil failed: \"(.*)\"").firstMatch(in: failure.assertion),
            let received = nilMatch.captures[0] {
            printWrongValue(expected: "nil", received: received)
        } else if failure.assertion != "failed" {
            stream.output("\t\(failure.assertion)")
        }
        if failure.assertion != "failed" {
            stream.output()
        }
        
        if let message = failure.message, !message.isEmpty {
            stream.output("\tNote: \(message)")
            stream.output()
        }
        stream.output("\tat \(fileLocation):\(failure.lineNumber)".dim)
        stream.output()
    }
    
    func printWrongValue(expected: String, received: String) {
        stream.output("\tExpected:")
        stream.output(expected.components(separatedBy: "\n").map{ "\t\($0)" }.joined(separator: "\n").green)
        stream.output("\tReceived:")
        stream.output(received.components(separatedBy: "\n").map{ "\t\($0)" }.joined(separator: "\n").red)
    }
    
    func stop() {
        if failures.isEmpty {
            stream.output("\r" + badge(text: "PASS", color: .green))
        }
    }
    
    func badge(text: String, color: BackgroundColor) -> String {
        return " \(text) ".applyingBackgroundColor(color).black.bold + " " + suiteName.bold
    }
    
}

private final class TestEndResponse: SimpleResponse {
    
    class Match: RegexMatch, Matchable {
        static let regex = Regex("Test Suite 'All tests' (passed|failed)")
    }
    
    static let countRegex = Regex("Executed ([0-9]+) tests, with ([0-9]*) failures? .* \\(([\\.0-9]+)\\) seconds$")
    
    let stream: StdStream = .err
    var nextLine = true
    
    init(match: Match) {}
    
    func go() {
        stream.output("")
    }
    
    func keepGoing(on line: String) -> Bool {
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

