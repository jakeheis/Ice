//
//  AssertionMatchers.swift
//  Transformers
//
//  Created by Jake Heiser on 9/14/17.
//

import Exec
import Regex
import SwiftCLI

let xctMatches: [XCTMatch.Type] = [
    XCTFailMatch.self, XCTEqualMatch.self, XCTNotEqualMatch.self, XCTEqualWithAccuracyMatch.self,
    XCTNotEqualWithAccuracyMatch.self, XCTGreaterThanMatch.self, XCTGreaterThanOrEqualMatch.self,
    XCTLessThanMatch.self, XCTLessThanOrEqualMatch.self, XCTNilMatch.self, XCTNotNilMatch.self,
    XCTTrueMatch.self, XCTFalseMatch.self, XCTThrowMatch.self, XCTNoThrowMatch.self
]

protocol XCTMatch: Match {
    var message: String { get }
    func output()
}

extension XCTMatch {

    var stderr: OutputByteStream {
        return OutputTransformer.stderr
    }
    
    func print(firstHeader: String, firstValue: String, secondValue: String) {
        func prepVal(_ val: String) -> String {
            let lines = val.components(separatedBy: AssertionFailureResponse.newlineReplacement)
            return lines.map{ "\t\($0)" }.joined(separator: "\n")
        }
        stderr <<< "\t\(firstHeader):"
        stderr <<< prepVal(firstValue).green
        stderr <<< "\tReceived:"
        stderr <<< prepVal(secondValue).red
        if secondValue.contains(AssertionFailureResponse.newlineReplacement) {
            stderr <<< "\t(end)"
        }
    }
    
    func printWrongValue(expected: String, received: String)  {
        print(firstHeader: "Expected", firstValue: expected, secondValue: received)
    }
    
}

final class XCTFailMatch: XCTMatch {
    static let regex = Regex("^failed - (.*)$")
    var message: String { return captures[0] }
    
    func output() {
        stderr <<< "\tXCTFail".red
    }
}

final class XCTEqualMatch: XCTMatch {
    static let regex = Regex("^XCTAssertEqual failed: \\(\"(.*)\"\\) is not equal to \\(\"(.*)\"\\) - (.*)$")
    var got: String { return captures[0] }
    var expected: String { return captures[1] }
    var message: String { return captures[2] }
    
    func output() {
        printWrongValue(expected: expected, received: got)
    }
}

final class XCTNotEqualMatch: XCTMatch {
    static let regex = Regex("^XCTAssertNotEqual failed: \\(\"(.*)\"\\) is equal to \\(\"(.*)\"\\) - (.*)$")
    var got: String { return captures[0] }
    var expected: String { return captures[1] }
    var message: String { return captures[2] }
    
    func output() {
        print(firstHeader: "Expected anything but", firstValue: expected, secondValue: got)
    }
}

final class XCTEqualWithAccuracyMatch: XCTMatch {
    static let regex = Regex("^XCTAssertEqualWithAccuracy failed: \\(\"(.*)\"\\) is not equal to \\(\"(.*)\"\\) \\+\\/- \\(\"(.*)\"\\) - (.*)$")
    var got: String { return captures[0] }
    var expected: String { return captures[1] }
    var accuracy: String { return captures[2] }
    var message: String { return captures[3] }
    
    func output() {
        print(firstHeader: "Expected", firstValue: expected + " (+/- \(accuracy))", secondValue: got)
    }
}

final class XCTNotEqualWithAccuracyMatch: XCTMatch {
    static let regex = Regex("^XCTAssertNotEqualWithAccuracy failed: \\(\"(.*)\"\\) is equal to \\(\"(.*)\"\\) \\+\\/- \\(\"(.*)\"\\) - (.*)$")
    var got: String { return captures[0] }
    var expected: String { return captures[1] }
    var accuracy: String { return captures[2] }
    var message: String { return captures[3] }
    
    func output() {
        print(firstHeader: "Expected anything but", firstValue: expected + " (+/- \(accuracy))", secondValue: got)
    }
}

final class XCTGreaterThanMatch: XCTMatch {
    static let regex = Regex("^XCTAssertGreaterThan failed: \\(\"(.*)\"\\) is not greater than \\(\"(.*)\"\\) - (.*)$")
    var got: String { return captures[0] }
    var expected: String { return captures[1] }
    var message: String { return captures[2] }
    
    func output() {
        print(firstHeader: "Expected value greater than", firstValue: expected, secondValue: got)
    }
}

final class XCTGreaterThanOrEqualMatch: XCTMatch {
    static let regex = Regex("^XCTAssertGreaterThanOrEqual failed: \\(\"(.*)\"\\) is less than \\(\"(.*)\"\\) - (.*)$")
    var got: String { return captures[0] }
    var expected: String { return captures[1] }
    var message: String { return captures[2] }
    
    func output() {
        print(firstHeader: "Expected value greater than or equal to", firstValue: expected, secondValue: got)
    }
}

final class XCTLessThanMatch: XCTMatch {
    static let regex = Regex("^XCTAssertLessThan failed: \\(\"(.*)\"\\) is not less than \\(\"(.*)\"\\) - (.*)$")
    var got: String { return captures[0] }
    var expected: String { return captures[1] }
    var message: String { return captures[2] }
    
    func output() {
        print(firstHeader: "Expected value less than", firstValue: expected, secondValue: got)
    }
}

final class XCTLessThanOrEqualMatch: XCTMatch {
    static let regex = Regex("^XCTAssertLessThanOrEqual failed: \\(\"(.*)\"\\) is greater than \\(\"(.*)\"\\) - (.*)$")
    var got: String { return captures[0] }
    var expected: String { return captures[1] }
    var message: String { return captures[2] }
    
    func output() {
        print(firstHeader: "Expected value less than or equal to", firstValue: expected, secondValue: got)
    }
}

final class XCTNilMatch: XCTMatch {
    static let regex = Regex("XCTAssertNil failed: \"(.*)\" - (.*)$")
    var value: String { return captures[0] }
    var message: String { return captures[1] }
    
    func output() {
        printWrongValue(expected: "nil", received: value)
    }
}

final class XCTNotNilMatch: XCTMatch {
    static let regex = Regex("XCTAssertNotNil failed - (.*)$")
    var message: String { return captures[0] }
    
    func output() {
        printWrongValue(expected: "non-nil", received: "nil")
    }
}

final class XCTTrueMatch: XCTMatch {
    static let regex = Regex("^XCTAssert(True)? failed - (.*)$")
    var message: String { return captures[1] }
    
    func output() {
        printWrongValue(expected: "true", received: "false")
    }
}

final class XCTFalseMatch: XCTMatch {
    static let regex = Regex("XCTAssertFalse failed - (.*)$")
    var message: String { return captures[0] }
    
    func output() {
        printWrongValue(expected: "false", received: "true")
    }
}

final class XCTThrowMatch: XCTMatch {
    static let regex = Regex("XCTAssertThrowsError failed: did not throw an error - (.*)$")
    var message: String { return captures[0] }
    
    func output() {
        printWrongValue(expected: "error thrown", received: "no error")
    }
}

final class XCTNoThrowMatch: XCTMatch {
    static let regex = Regex("XCTAssertNoThrow failed: threw error \"(.*)\" - (.*)$")
    var error: String { return captures[0] }
    var message: String { return captures[1] }
    
    func output() {
        printWrongValue(expected: "no error", received: error)
    }
}
