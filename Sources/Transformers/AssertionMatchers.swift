//
//  AssertionMatchers.swift
//  Transformers
//
//  Created by Jake Heiser on 9/14/17.
//

import Exec
import Regex
import SwiftCLI

protocol XCTMatchable: Matchable {
    var message: String { get }
    func print(to out: WriteStream)
}

extension XCTMatchable {
    
    func print(firstHeader: String, firstValue: String, secondValue: String, out: WriteStream) {
        func prepVal(_ val: String) -> String {
            let lines = val.components(separatedBy: AssertionFailure.newlineReplacement)
            return lines.map{ "\t\($0)" }.joined(separator: "\n")
        }
        out <<< "\t\(firstHeader):"
        out <<< prepVal(firstValue).green
        out <<< "\tReceived:"
        out <<< prepVal(secondValue).red
        if secondValue.contains(AssertionFailure.newlineReplacement) {
            out <<< "\t(end)"
        }
    }
    
    func printWrongValue(expected: String, received: String, out: WriteStream)  {
        print(firstHeader: "Expected", firstValue: expected, secondValue: received, out: out)
    }
    
}

// MARK: -

typealias XCTMatcher = Matcher & XCTMatchable

let xctMatches: [XCTMatcher.Type] = [
    XCTFailMatch.self, XCTEqualMatch.self, XCTNotEqualMatch.self, XCTEqualWithAccuracyMatch.self,
    XCTNotEqualWithAccuracyMatch.self, XCTGreaterThanMatch.self, XCTGreaterThanOrEqualMatch.self,
    XCTLessThanMatch.self, XCTLessThanOrEqualMatch.self, XCTNilMatch.self, XCTNotNilMatch.self,
    XCTTrueMatch.self, XCTFalseMatch.self, XCTThrowMatch.self, XCTNoThrowMatch.self
]

// MARK: -

final class XCTFailMatch: Matcher, XCTMatchable {
    static let regex = Regex("^failed - (.*)$")
    var message: String { return captures[0] }
    
    func print(to out: WriteStream) {
        out <<< "\tXCTFail".red
    }
}

final class XCTEqualMatch: Matcher, XCTMatchable {
    static let regex = Regex("^XCTAssertEqual failed: \\(\"(.*)\"\\) is not equal to \\(\"(.*)\"\\) - (.*)$")
    var got: String { return captures[0] }
    var expected: String { return captures[1] }
    var message: String { return captures[2] }
    
    func print(to out: WriteStream) {
        printWrongValue(expected: expected, received: got, out: out)
    }
}

final class XCTNotEqualMatch: Matcher, XCTMatchable {
    static let regex = Regex("^XCTAssertNotEqual failed: \\(\"(.*)\"\\) is equal to \\(\"(.*)\"\\) - (.*)$")
    var got: String { return captures[0] }
    var expected: String { return captures[1] }
    var message: String { return captures[2] }
    
    func print(to out: WriteStream) {
        print(firstHeader: "Expected anything but", firstValue: expected, secondValue: got, out: out)
    }
}

final class XCTEqualWithAccuracyMatch: Matcher, XCTMatchable {
    static let regex = Regex("^XCTAssertEqualWithAccuracy failed: \\(\"(.*)\"\\) is not equal to \\(\"(.*)\"\\) \\+\\/- \\(\"(.*)\"\\) - (.*)$")
    var got: String { return captures[0] }
    var expected: String { return captures[1] }
    var accuracy: String { return captures[2] }
    var message: String { return captures[3] }
    
    func print(to out: WriteStream) {
        print(firstHeader: "Expected", firstValue: expected + " (+/- \(accuracy))", secondValue: got, out: out)
    }
}

final class XCTNotEqualWithAccuracyMatch: Matcher, XCTMatchable {
    static let regex = Regex("^XCTAssertNotEqualWithAccuracy failed: \\(\"(.*)\"\\) is equal to \\(\"(.*)\"\\) \\+\\/- \\(\"(.*)\"\\) - (.*)$")
    var got: String { return captures[0] }
    var expected: String { return captures[1] }
    var accuracy: String { return captures[2] }
    var message: String { return captures[3] }
    
    func print(to out: WriteStream) {
        print(firstHeader: "Expected anything but", firstValue: expected + " (+/- \(accuracy))", secondValue: got, out: out)
    }
}

final class XCTGreaterThanMatch: Matcher, XCTMatchable {
    static let regex = Regex("^XCTAssertGreaterThan failed: \\(\"(.*)\"\\) is not greater than \\(\"(.*)\"\\) - (.*)$")
    var got: String { return captures[0] }
    var expected: String { return captures[1] }
    var message: String { return captures[2] }
    
    func print(to out: WriteStream) {
        print(firstHeader: "Expected value greater than", firstValue: expected, secondValue: got, out: out)
    }
}

final class XCTGreaterThanOrEqualMatch: Matcher, XCTMatchable {
    static let regex = Regex("^XCTAssertGreaterThanOrEqual failed: \\(\"(.*)\"\\) is less than \\(\"(.*)\"\\) - (.*)$")
    var got: String { return captures[0] }
    var expected: String { return captures[1] }
    var message: String { return captures[2] }
    
    func print(to out: WriteStream) {
        print(firstHeader: "Expected value greater than or equal to", firstValue: expected, secondValue: got, out: out)
    }
}

final class XCTLessThanMatch: Matcher, XCTMatchable {
    static let regex = Regex("^XCTAssertLessThan failed: \\(\"(.*)\"\\) is not less than \\(\"(.*)\"\\) - (.*)$")
    var got: String { return captures[0] }
    var expected: String { return captures[1] }
    var message: String { return captures[2] }
    
    func print(to out: WriteStream) {
        print(firstHeader: "Expected value less than", firstValue: expected, secondValue: got, out: out)
    }
}

final class XCTLessThanOrEqualMatch: Matcher, XCTMatchable {
    static let regex = Regex("^XCTAssertLessThanOrEqual failed: \\(\"(.*)\"\\) is greater than \\(\"(.*)\"\\) - (.*)$")
    var got: String { return captures[0] }
    var expected: String { return captures[1] }
    var message: String { return captures[2] }
    
    func print(to out: WriteStream) {
        print(firstHeader: "Expected value less than or equal to", firstValue: expected, secondValue: got, out: out)
    }
}

final class XCTNilMatch: Matcher, XCTMatchable {
    static let regex = Regex("XCTAssertNil failed: \"(.*)\" - (.*)$")
    var value: String { return captures[0] }
    var message: String { return captures[1] }
    
    func print(to out: WriteStream) {
        printWrongValue(expected: "nil", received: value, out: out)
    }
}

final class XCTNotNilMatch: Matcher, XCTMatchable {
    static let regex = Regex("XCTAssertNotNil failed - (.*)$")
    var message: String { return captures[0] }
    
    func print(to out: WriteStream) {
        printWrongValue(expected: "non-nil", received: "nil", out: out)
    }
}

final class XCTTrueMatch: Matcher, XCTMatchable {
    static let regex = Regex("^XCTAssert(True)? failed - (.*)$")
    var message: String { return captures[1] }
    
    func print(to out: WriteStream) {
        printWrongValue(expected: "true", received: "false", out: out)
    }
}

final class XCTFalseMatch: Matcher, XCTMatchable {
    static let regex = Regex("XCTAssertFalse failed - (.*)$")
    var message: String { return captures[0] }
    
    func print(to out: WriteStream) {
        printWrongValue(expected: "false", received: "true", out: out)
    }
}

final class XCTThrowMatch: Matcher, XCTMatchable {
    static let regex = Regex("XCTAssertThrowsError failed: did not throw an error - (.*)$")
    var message: String { return captures[0] }
    
    func print(to out: WriteStream) {
        printWrongValue(expected: "error thrown", received: "no error", out: out)
    }
}

final class XCTNoThrowMatch: Matcher, XCTMatchable {
    static let regex = Regex("XCTAssertNoThrow failed: threw error \"(.*)\" - (.*)$")
    var error: String { return captures[0] }
    var message: String { return captures[1] }
    
    func print(to out: WriteStream) {
        printWrongValue(expected: "no error", received: error, out: out)
    }
}
