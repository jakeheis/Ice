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
    
    static let doneRegex = Regex("Executed .* tests?")
    
    let suiteName: String
    let stream: StdStream = .err
    
    private var failed = false
    private var done = false
    
    var currentTestCase: TestCaseResponse?
    
    init(match: Match) {
        self.suiteName = match.suiteName
    }
    
    func go() {
        stream.output(badge(text: "RUNS", color: .blue), terminator: "")
    }
    
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
        
        if let match = TestCaseResponse.Match.match(line) {
            // Start test case
            let response = TestCaseResponse(testSuite: self, match: match)
            response.go()
            currentTestCase = response
            return true
        }
        
        if Match.match(line) != nil {
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
        stream.output("\r" + badge(text: "FAIL", color: .red))
        stream.output("")
        failed = true
    }
    
    func stop() {
        if failed == false {
            stream.output("\r" + badge(text: "PASS", color: .green))
        }
    }
    
    func badge(text: String, color: BackgroundColor) -> String {
        return " \(text) ".applyingBackgroundColor(color).black.bold + " " + suiteName.bold
    }
    
}

private final class TestCaseResponse: Response {
    
    class Match: RegexMatch, Matchable {
        enum Status: String, Capturable {
            case started
            case passed
            case failed
        }
        
        static let regex = Regex("^Test Case .* ([^ ]*)\\]' (started|passed|failed)")
        var caseName: String { return captures[0] }
        var status: Status { return captures[1] }
    }
    
    class FatalErrorMatch: RegexMatch, Matchable {
        static let regex = Regex("^fatal error: (.*)$")
        var message: String { return captures[0] }
    }
    
    let testSuite: TestSuiteResponse
    let caseName: String
    
    var status: Match.Status = .started
    var currentAssertionFailure: AssertionResponse?
    
    init(testSuite: TestSuiteResponse, match: Match) {
        self.testSuite = testSuite
        self.caseName = match.caseName
    }
    
    func go() {}
    
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
        if let match = AssertionResponse.Match.match(line) {
            // Start assertion
            testSuite.markFailed()
            StdStream.err.output(" ● \(caseName)".red.bold)
            
            let assertionFailure = AssertionResponse(match: match)
            assertionFailure.go()
            self.currentAssertionFailure = assertionFailure
            return true
        }
        
        if let match = Match.match(line) {
            status = match.status
            return true
        }
        
        if let match = FatalErrorMatch.match(line) {
            testSuite.markFailed()
            StdStream.err.output("Fatal error: ".red.bold + match.message)
            return true
        }
        
        fatalError("\n\nError: unexpected output: \(line)\n\n")
    }
    
    func stop() {}
    
}

protocol XCTMatchable: Matchable {
    var message: String { get }
}

private final class AssertionResponse: Response {
    
    class Match: RegexMatch, Matchable {
        static let regex = Regex("(.*):([0-9]+): error: .* : (.*)$")
        var file: String { return captures[0] }
        var lineNumber: Int { return captures[1] }
        var assertion: String { return captures[2] }
    }
    
    // XCTAssertNil
    class XCTNilMatch: RegexMatch, XCTMatchable {
        static let regex = Regex("XCTAssertNil failed: \"(.*)\" - (.*)$")
        var value: String { return captures[0] }
        var message: String { return captures[1] }
    }
    
    // XCTAssertEqual, XCTAssertGreaterThan, XCTAssertGreaterThanOrEqual, XCTAssertLessThan, XCTAssertLessThanOrEqual, XCTAssertNotEqual
    class XCTInfixMatch: RegexMatch, XCTMatchable {
        static let regex = Regex("(XCTAssert[^ ]*) failed: \\(\"(.*)\"\\) is (.*) \\(\"(.*)\"\\) - (.*)$")
        var type: String { return captures[0] }
        var got: String { return captures[1] }
        var comparison: String { return captures[2] }
        var expected: String { return captures[3] }
        var message: String { return captures[4] }
    }
    
    // XCTAssert, XCTAssertFalse, XCTAssertNotNil, XCTAssertTrue
    class XCTBooleanMatch: RegexMatch, XCTMatchable {
        static let regex = Regex("XCTAssert(True|False|NotNil|) failed - (.*)$")
        var type: String { return captures[0] }
        var message: String { return captures[1] }
    }
    
    // XCTAssertThrowsError
    class XCTThrowMatch: RegexMatch, XCTMatchable {
        static let regex = Regex("XCTAssertThrowsError failed: did not throw an error - (.*)$")
        var message: String { return captures[0] }
    }
    
    // XCTAssertNoThrow
    class XCTNoThrowMatch: RegexMatch, XCTMatchable {
        static let regex = Regex("XCTAssertNoThrow failed: threw error \"(.*)\" - (.*)$")
        var error: String { return captures[0] }
        var message: String { return captures[1] }
    }
    
//    class XctMatch: RegexMatch, Matchable {
//        static let regex = Regex("(XCT[^ ]*) failed(: .*)? - (.*)$")
//        var type: String { return captures[0] }
//        var info: String? { return captures[1] }
//        var message: String { return captures[2] }
//    }
    
    static let newlineReplacement = "______$$$$$$$$"
    
    let file: String
    let lineNumber: Int
    var assertion: String
//    var message: String?
    
    let stream = StdStream.err
    
    init(match: Match) {
        self.file = match.file
        self.lineNumber = match.lineNumber
        self.assertion = match.assertion
//        self.message = match.message
//        print(match.captures)
    }
    
    func go() {}
    
    func keepGoing(on line: String) -> Bool {
        if AssertionResponse.Match.matches(line)
            || TestCaseResponse.FatalErrorMatch.matches(line)
            || TestCaseResponse.Match.matches(line) {
            return false
        }
        
        assertion += AssertionResponse.newlineReplacement + line
        
//        guard message == nil else {
//            return false
//        }
//
//        if let match = MultilineLastLineMatch.match(line) {
//            // Last line
//            assertion += "\n" + match.assertion
//            message = match.message
//        } else {
//            // Middle line
//            assertion += "\n" + line
//        }
        return true
    }
    
    func stop() {
//        guard let xctMatch = XctMatch.match(assertion) else {
//            print(assertion)
//            return
//        }
        
//        print("\n\ndealing with assertion:")
//        print(assertion)
//        print()
        
        func convert(_ str: String) -> String {
            return str.replacingOccurrences(of: AssertionResponse.newlineReplacement, with: "\n")
        }
        
        stream.output()
        
        let xct: XCTMatchable
        if let match = XCTNilMatch.match(assertion) {
            printWrongValue(
                expected: "nil",
                received: convert(match.value)
            )
            xct = match
        } else if let match = XCTInfixMatch.match(assertion) {
            if match.type == "XCTAssertEqual" {
                printWrongValue(
                    expected: convert(match.expected),
                    received: convert(match.got)
                )
            } else if match.type == "XCTAssertNotEqual" {
                printWrongValue(
                    expected: convert(match.expected),
                    received: convert(match.got),
                    secondHeader: "not to equal"
                )
            } else {
                stream.output("\tError: ".red  + "\(match.got.red) is \(match.comparison) \(match.expected.red)")
            }
            xct = match
        } else if let match = XCTBooleanMatch.match(assertion) {
            if match.type == "" || match.type == "True" {
                printWrongValue(
                    expected: "true",
                    received: "false"
                )
            } else if match.type == "NotNil" {
                printWrongValue(
                    expected: "not nil",
                    received: "nil"
                )
            } else if match.type == "False" {
                printWrongValue(
                    expected: "false",
                    received: "true"
                )
            } else {
                printWrongValue(
                    expected: match.type.lowercased(),
                    received: "not " + match.type.lowercased()
                )
            }
            xct = match
        } else if let match = XCTThrowMatch.match(assertion) {
            printWrongValue(
                expected: "expression to throw",
                received: "no throw"
            )
            xct = match
        } else if let match = XCTNoThrowMatch.match(assertion) {
            printWrongValue(
                expected: "expression not to throw",
                received: convert(match.error),
                secondHeader: "Threw"
            )
            xct = match
        } else {
            print("\n\n\nWarning: Unrecognized error\n\n\n".red.bold)
            print(assertion)
            return
        }
        
        if !xct.message.isEmpty {
            stream.output()
            let lines = convert(xct.message).components(separatedBy: "\n")
            var message = lines[0]
            if lines.count > 1 {
                message += "\n" + lines.dropFirst().map({ "\t\($0)" }).joined(separator: "\n")
            }
            stream.output("\tNote: \(message)")
        }
        
        let fileLocation = file.trimmingCurrentDirectory
        stream.output()
        stream.output("\tat \(fileLocation):\(lineNumber)".dim)
        stream.output()
    }
    
    func printWrongValue(expected: String, received: String, secondHeader: String = "Received") {
        stream.output("\tExpected:")
        stream.output(expected.components(separatedBy: "\n").map{ "\t\($0)" }.joined(separator: "\n").green)
        stream.output("\t\(secondHeader):")
        stream.output(received.components(separatedBy: "\n").map{ "\t\($0)" }.joined(separator: "\n").red)
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
