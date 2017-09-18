//
//  AssertionMatchers.swift
//  Transformers
//
//  Created by Jake Heiser on 9/14/17.
//

import Exec
import Regex
import SwiftCLI

typealias XCTMatcher = RegexMatch & XCTMatchable

let xctMatches: [XCTMatcher.Type] = [
    XCTFailMatch.self, XCTEqualMatch.self, XCTNotEqualMatch.self, XCTEqualWithAccuracyMatch.self,
    XCTNotEqualWithAccuracyMatch.self, XCTGreaterThanMatch.self, XCTGreaterThanOrEqualMatch.self,
    XCTLessThanMatch.self, XCTLessThanOrEqualMatch.self, XCTNilMatch.self, XCTNotNilMatch.self,
    XCTTrueMatch.self, XCTFalseMatch.self, XCTThrowMatch.self, XCTNoThrowMatch.self
]

protocol XCTMatchable: Matchable {
    var message: String { get }
    func output()
}

extension XCTMatchable {

    var stderr: OutputByteStream {
        return OutputTransformer.stderr
    }
    
    func print(firstHeader: String, firstValue: String, secondValue: String) {
        stderr <<< "\t\(firstHeader):"
        stderr <<< firstValue.components(separatedBy: AssertionResponse.newlineReplacement).map{ "\t\($0)" }.joined(separator: "\n").green
        stderr <<< "\tReceived:"
        stderr <<< secondValue.components(separatedBy: AssertionResponse.newlineReplacement).map{ "\t\($0)" }.joined(separator: "\n").red
    }
    
    func printWrongValue(expected: String, received: String)  {
        print(firstHeader: "Expected", firstValue: expected, secondValue: received)
    }
    
}

class XCTFailMatch: RegexMatch, XCTMatchable {
    static let regex = Regex("^failed - (.*)$")
    var message: String { return captures[0] }
    
    func output() {
        stderr <<< "\tXCTFail".red
    }
}

class XCTEqualMatch: RegexMatch, XCTMatchable {
    static let regex = Regex("^XCTAssertEqual failed: \\(\"(.*)\"\\) is not equal to \\(\"(.*)\"\\) - (.*)$")
    var got: String { return captures[0] }
    var expected: String { return captures[1] }
    var message: String { return captures[2] }
    
    func output() {
        printWrongValue(expected: expected, received: got)
    }
}

class XCTNotEqualMatch: RegexMatch, XCTMatchable {
    static let regex = Regex("^XCTAssertNotEqual failed: \\(\"(.*)\"\\) is equal to \\(\"(.*)\"\\) - (.*)$")
    var got: String { return captures[0] }
    var expected: String { return captures[1] }
    var message: String { return captures[2] }
    
    func output() {
        print(firstHeader: "Expected anything but", firstValue: expected, secondValue: got)
    }
}

class XCTEqualWithAccuracyMatch: RegexMatch, XCTMatchable {
    static let regex = Regex("^XCTAssertEqualWithAccuracy failed: \\(\"(.*)\"\\) is not equal to \\(\"(.*)\"\\) \\+\\/- \\(\"(.*)\"\\) - (.*)$")
    var got: String { return captures[0] }
    var expected: String { return captures[1] }
    var accuracy: String { return captures[2] }
    var message: String { return captures[3] }
    
    func output() {
        print(firstHeader: "Expected", firstValue: expected + " (+/- \(accuracy))", secondValue: got)
    }
}

class XCTNotEqualWithAccuracyMatch: RegexMatch, XCTMatchable {
    static let regex = Regex("^XCTAssertNotEqualWithAccuracy failed: \\(\"(.*)\"\\) is equal to \\(\"(.*)\"\\) \\+\\/- \\(\"(.*)\"\\) - (.*)$")
    var got: String { return captures[0] }
    var expected: String { return captures[1] }
    var accuracy: String { return captures[2] }
    var message: String { return captures[3] }
    
    func output() {
        print(firstHeader: "Expected anything but", firstValue: expected + " (+/- \(accuracy))", secondValue: got)
    }
}

class XCTGreaterThanMatch: RegexMatch, XCTMatchable {
    static let regex = Regex("^XCTAssertGreaterThan failed: \\(\"(.*)\"\\) is not greater than \\(\"(.*)\"\\) - (.*)$")
    var got: String { return captures[0] }
    var expected: String { return captures[1] }
    var message: String { return captures[2] }
    
    func output() {
        print(firstHeader: "Expected value greater than", firstValue: expected, secondValue: got)
    }
}

class XCTGreaterThanOrEqualMatch: RegexMatch, XCTMatchable {
    static let regex = Regex("^XCTAssertGreaterThanOrEqual failed: \\(\"(.*)\"\\) is less than \\(\"(.*)\"\\) - (.*)$")
    var got: String { return captures[0] }
    var expected: String { return captures[1] }
    var message: String { return captures[2] }
    
    func output() {
        print(firstHeader: "Expected value greater than or equal to", firstValue: expected, secondValue: got)
    }
}

class XCTLessThanMatch: RegexMatch, XCTMatchable {
    static let regex = Regex("^XCTAssertLessThan failed: \\(\"(.*)\"\\) is not less than \\(\"(.*)\"\\) - (.*)$")
    var got: String { return captures[0] }
    var expected: String { return captures[1] }
    var message: String { return captures[2] }
    
    func output() {
        print(firstHeader: "Expected value less than", firstValue: expected, secondValue: got)
    }
}

class XCTLessThanOrEqualMatch: RegexMatch, XCTMatchable {
    static let regex = Regex("^XCTAssertLessThanOrEqual failed: \\(\"(.*)\"\\) is greater than \\(\"(.*)\"\\) - (.*)$")
    var got: String { return captures[0] }
    var expected: String { return captures[1] }
    var message: String { return captures[2] }
    
    func output() {
        print(firstHeader: "Expected value less than or equal to", firstValue: expected, secondValue: got)
    }
}

class XCTNilMatch: RegexMatch, XCTMatchable {
    static let regex = Regex("XCTAssertNil failed: \"(.*)\" - (.*)$")
    var value: String { return captures[0] }
    var message: String { return captures[1] }
    
    func output() {
        printWrongValue(expected: "nil", received: value)
    }
}

class XCTNotNilMatch: RegexMatch, XCTMatchable {
    static let regex = Regex("XCTAssertNotNil failed - (.*)$")
    var message: String { return captures[0] }
    
    func output() {
        printWrongValue(expected: "non-nil", received: "nil")
    }
}

class XCTTrueMatch: RegexMatch, XCTMatchable {
    static let regex = Regex("^XCTAssert(True)? failed - (.*)$")
    var message: String { return captures[1] }
    
    func output() {
        printWrongValue(expected: "true", received: "false")
    }
}

class XCTFalseMatch: RegexMatch, XCTMatchable {
    static let regex = Regex("XCTAssertFalse failed - (.*)$")
    var message: String { return captures[0] }
    
    func output() {
        printWrongValue(expected: "false", received: "true")
    }
}

class XCTThrowMatch: RegexMatch, XCTMatchable {
    static let regex = Regex("XCTAssertThrowsError failed: did not throw an error - (.*)$")
    var message: String { return captures[0] }
    
    func output() {
        printWrongValue(expected: "error thrown", received: "no error")
    }
}

class XCTNoThrowMatch: RegexMatch, XCTMatchable {
    static let regex = Regex("XCTAssertNoThrow failed: threw error \"(.*)\" - (.*)$")
    var error: String { return captures[0] }
    var message: String { return captures[1] }
    
    func output() {
        printWrongValue(expected: "no error", received: error)
    }
}
//
//// XCTAssertEqual, XCTAssertGreaterThan, XCTAssertGreaterThanOrEqual, XCTAssertLessThan, XCTAssertLessThanOrEqual, XCTAssertNotEqual
//class XCTInfixMatch: RegexMatch, XCTMatchable {
//    static let regex = Regex("(XCTAssert[^ ]*) failed: \\(\"(.*)\"\\) is (.*) \\(\"(.*)\"\\) - (.*)$")
//    var type: String { return captures[0] }
//    var got: String { return captures[1] }
//    var comparison: String { return captures[2] }
//    var expected: String { return captures[3] }
//    var message: String { return captures[4] }
//}
//
//// XCTAssert, XCTAssertFalse, XCTAssertNotNil, XCTAssertTrue
//class XCTBooleanMatch: RegexMatch, XCTMatchable {
//    static let regex = Regex("XCTAssert(True|False|NotNil|) failed - (.*)$")
//    var type: String { return captures[0] }
//    var message: String { return captures[1] }
//}
//
//// XCTAssertThrowsError
//class XCTThrowMatch: RegexMatch, XCTMatchable {
//    static let regex = Regex("XCTAssertThrowsError failed: did not throw an error - (.*)$")
//    var message: String { return captures[0] }
//}
//
//// XCTAssertNoThrow
//class XCTNoThrowMatch: RegexMatch, XCTMatchable {
//    static let regex = Regex("XCTAssertNoThrow failed: threw error \"(.*)\" - (.*)$")
//    var error: String { return captures[0] }
//    var message: String { return captures[1] }
//}

