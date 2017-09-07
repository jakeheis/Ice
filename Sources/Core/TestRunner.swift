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
                t.spin("Compile Swift Module '(.*)'", { "Compiling " + $0[0] }, { (s, c, _) in s.succeed(text: "Compiled " + c[0]) })
                t.ignore("^Test Suite 'All tests' started", on: .err)
                t.replace("^Test Suite '(.*)\\.xctest' started", on: .err, { "\n\($0[0]):\n".dim })
                t.ignore("^Test Suite '(.*)\\.xctest'", on: .err)
                t.respond(on: .err, with: ResponseGenerator(matcher: "^Test Suite 'All tests' (passed|failed)", generate: {
                    return TestEndResponse()
                }))
                t.respond(on: .err, with: ResponseGenerator(matcher: "^Test Suite '(.*)'", generate: {
                    return TestSuiteResponse()
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

private class TestSuiteResponse: Response {
    
    static let caseRegex = Regex("^Test Case .* ([^ ]*)\\]' (started|passed|failed)")
    static let doneRegex = Regex("Executed .* tests")
    static let xctFailureRegex = Regex("(.*):([0-9]+): error: .* : (.*) - (.*)$")
    
    struct AssertionFailure {
        let file: String
        let lineNumber: Int
        let assertion: String?
        let message: String?
    }
    
    let stream: StdStream = .err
    var suiteName: String?
    
    var done = false
    var failures: [String] = []
    var currentAssertionFailures: [AssertionFailure] = []
    
    func go(captures: [String]) {
        suiteName = captures[0]
        stream.output(badge(text: "RUNS", color: .blue), terminator: "")
    }
    
    func keepGoing(on line: String) -> Bool {
        guard !done else {
            return false
        }
        done = TestSuiteResponse.doneRegex.matches(line)
        if let xctFailure = TestSuiteResponse.xctFailureRegex.firstMatch(in: line) {
            currentAssertionFailures.append(AssertionFailure(
                file: xctFailure.captures[0]!,
                lineNumber: Int(xctFailure.captures[1]!)!,
                assertion: xctFailure.captures[2]?.trimmed,
                message: xctFailure.captures[3]?.trimmed
            ))
        }
        if let match = TestSuiteResponse.caseRegex.firstMatch(in: line) {
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
        }
        return true
    }
    
    func printAssertionFailure(_ failure: AssertionFailure) {
        stream.output()
        let fileLocation = failure.file.trimmingCurrentDirectory
        if let assertion = failure.assertion {
            if let equalsMatch = Regex("\\(\"(.*)\"\\) is not equal to \\(\"(.*)\"\\)").firstMatch(in: assertion),
                let received = equalsMatch.captures[0], let expected = equalsMatch.captures[1] {
                printWrongValue(expected: expected, received: received)
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
        stream.output("\t  \(expected)".green)
        stream.output("\tReceived:")
        stream.output("\t  \(received)".red)
    }
    
    func stop() {
        if failures.isEmpty {
            stream.output("\r" + badge(text: "PASS", color: .green))
        }
    }
    
    func badge(text: String, color: BackgroundColor) -> String {
        return " \(text) ".applyingBackgroundColor(color).black.bold + " " + suiteName!.bold
    }
    
}

private class TestEndResponse: Response {
    
    static let countRegex = Regex("Executed ([0-9]+) tests, with ([0-9]*) failures? .* \\(([\\.0-9]+)\\) seconds$")
    
    let stream: StdStream = .err
    var nextLine = true
    
    func go(captures: [String]) {
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
