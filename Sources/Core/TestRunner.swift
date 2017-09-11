//
//  TestResponses.swift
//  Core
//
//  Created by Jake Heiser on 9/5/17.
//

import Exec
import Regex
import Rainbow
import Files

extension SPM {
    
    public func test() throws {
        do {
            try exec(arguments: ["test"]).execute(transform: { (t) in
                self.transformBuild(t)
                t.ignore("^Test Suite 'All tests' started", on: .err)
                t.replace("^Test Suite '(.*)\\.xctest' started", PackageTestsBegunMatch.self, on: .err) {
                    "\n\($0.packageName):\n".bold
                }
                t.ignore("^Test Suite '(.*)\\.xctest'", on: .err)
                t.respond(on: .err, with: ResponseGenerator(matcher: "Test Suite 'All tests' (passed|failed)", generate: { (_) in
                    return TestEndResponse()
                }))
                t.respond(on: .err, with: ResponseGenerator(matcher: "^Test Suite '(.*)'", generate: {
                    return TestSuiteResponse(match: $0)
                }))
                t.ignore("Executed [0-9]+ tests", on: .err)
                t.ignore(".*", on: .out)
                t.last("\n")
            })
        } catch let error as Exec.Error {
            throw IceError(exitStatus: error.exitStatus)
        }
    }
    
}

class PackageTestsBegunMatch: RegexMatch {
    var packageName: String { return captures[0] }
}

class TestSuiteMatch: RegexMatch {
    var suiteName: String { return captures[0] }
}

private class TestSuiteResponse: Response {
    
    public typealias Match = TestSuiteMatch
    
    static let caseRegex = Regex("^Test Case .* ([^ ]*)\\]' (started|passed|failed)")
    static let doneRegex = Regex("Executed .* tests")
    static let xctFailureRegex = Regex("(.*):([0-9]+): error: .* : (.*)( - (.*))?$")
    static let remainingRegex = Regex("(.*) - (.*)$")
    
    struct AssertionFailure {
        let file: String
        let lineNumber: Int
        var assertion: String?
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
        } else if let xctFailure = TestSuiteResponse.xctFailureRegex.firstMatch(in: line) {
            currentAssertionFailures.append(AssertionFailure(
                file: xctFailure.captures[0]!,
                lineNumber: Int(xctFailure.captures[1]!)!,
                assertion: xctFailure.captures[2]?.trimmed,
                message: xctFailure.captures[3]?.trimmed
            ))
        } else if let match = TestSuiteResponse.caseRegex.firstMatch(in: line) {
            if match.captures[1] == "failed" {
                if failures.isEmpty {
                    stream.output("\r" + badge(text: "FAIL", color: .red))
                    stream.output("")
                }
                failures.append(match.captures[0]!)
                stream.output(" ● \(match.captures[0]!)".red.bold)
                
                for failure in currentAssertionFailures {
                    printAssertionFailure(failure)
                }
            }
            currentAssertionFailures = []
        } else if let match = TestSuiteResponse.remainingRegex.firstMatch(in: line) {
            if var failure = currentAssertionFailures.last {
                failure.assertion =  (failure.assertion ?? "") + "\n" + (match.captures[0] ?? "")
                failure.message = match.captures[1]
                currentAssertionFailures[currentAssertionFailures.count - 1] = failure
            }
        } else {
            if var failure = currentAssertionFailures.last {
                failure.assertion =  (failure.assertion ?? "") + "\n"  + line
                currentAssertionFailures[currentAssertionFailures.count - 1] = failure
            }
        }
        return true
    }
    
    func printAssertionFailure(_ failure: AssertionFailure) {
        stream.output()
        let fileLocation = failure.file.trimmingCurrentDirectory
        if let assertion = failure.assertion {
            let lineBreak = "________"
            let totalMessage = assertion.replacingOccurrences(of: "\n", with: lineBreak)
            if let equalsMatch = Regex("\\(\"(.*)\"\\) is not equal to \\(\"(.*)\"\\)").firstMatch(in: totalMessage),
                let received = equalsMatch.captures[0], let expected = equalsMatch.captures[1] {
                printWrongValue(
                    expected: expected.replacingOccurrences(of: lineBreak, with: "\n"),
                    received: received.replacingOccurrences(of: lineBreak, with: "\n")
                )
            } else if let nilMatch = Regex("XCTAssertNil failed: \"(.*)\"").firstMatch(in: assertion),
                let received = nilMatch.captures[0] {
                printWrongValue(expected: "nil", received: received)
            } else if assertion != "failed" {
                stream.output("\t\(assertion)")
            }
            if assertion != "failed" {
                stream.output()
            }
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

private class TestEndResponse: Response {
    
    public typealias Match = RegexMatch
    
    static let countRegex = Regex("Executed ([0-9]+) tests, with ([0-9]*) failures? .* \\(([\\.0-9]+)\\) seconds$")
    
    let stream: StdStream = .err
    var nextLine = true
    
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
