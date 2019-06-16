//
//  AssertionMatchers.swift
//  Transformers
//
//  Created by Jake Heiser on 9/14/17.
//

import SwiftCLI

protocol XCTMatchable: Matchable {
    var message: String? { get }
    func print(to out: WritableStream)
}

extension XCTMatchable {
    
    func print(firstHeader: String, firstValue: String, secondValue: String, out: WritableStream) {
        func prepVal(_ val: String) -> String {
            let lines = val.components(separatedBy: AssertionFailure.newlineReplacement)
            return lines.map{ "\t\($0)" }.joined(separator: "\n")
        }
        out <<< "\t\(firstHeader):"
        if firstValue.isEmpty {
            out <<< "\t(empty string)".dim
        } else {
            out <<< prepVal(firstValue).green
        }
        out <<< "\tReceived:"
        if secondValue.isEmpty {
            out <<< "\t(empty string)".dim
        } else {
            out <<< prepVal(secondValue).red
        }
        if secondValue.contains(AssertionFailure.newlineReplacement) {
            out <<< "\t(end)"
        }
    }
    
    func printWrongValue(expected: String, received: String, out: WritableStream)  {
        print(firstHeader: "Expected", firstValue: expected, secondValue: received, out: out)
    }
    
}

// MARK: -

typealias XCTMatcher = Matcher & XCTMatchable

let xctMatches: [XCTMatcher.Type] = [
    XCTFailMatch.self, XCTEqualMatch.self, XCTNotEqualMatch.self, XCTEqualWithAccuracyMatch.self,
    XCTNotEqualWithAccuracyMatch.self, XCTGreaterThanMatch.self, XCTGreaterThanOrEqualMatch.self,
    XCTLessThanMatch.self, XCTLessThanOrEqualMatch.self, XCTNilMatch.self, XCTNotNilMatch.self,
    XCTTrueMatch.self, XCTFalseMatch.self, XCTThrowMatch.self, XCTNoThrowMatch.self, XCTAssertMatch.self
]

// MARK: -

protocol ZerofoldXCTMatchable: XCTMatchable {
    static var text: String { get }
    static var expected: String { get }
    static var received: String { get }
}

extension ZerofoldXCTMatchable where Self: Matcher {
    static var regex: Regex {
        return Regex(unsafePattern: "^\(text)( - (.*))?$")
    }

    var message: String? { return captures[1] }
    
    func print(to out: WritableStream) {
        printWrongValue(expected: Self.expected, received: Self.received, out: out)
    }
}

final class XCTFalseMatch: Matcher, ZerofoldXCTMatchable {
    static let text = "XCTAssertFalse failed"
    static let expected = "false"
    static let received = "true"
}

final class XCTThrowMatch: Matcher, ZerofoldXCTMatchable {
    static let text = "XCTAssertThrowsError failed: did not throw an error"
    static let expected = "error thrown"
    static let received = "no error"
}

final class XCTNotNilMatch: Matcher, ZerofoldXCTMatchable {
    static let text = "XCTAssertNotNil failed"
    static let expected = "non-nil"
    static let received = "nil"
}

final class XCTTrueMatch: Matcher, ZerofoldXCTMatchable {
    static let text = "XCTAssertTrue failed"
    static let expected = "true"
    static let received = "false"
}

final class XCTAssertMatch: Matcher, ZerofoldXCTMatchable {
    static let text = "XCTAssert failed"
    static let expected = "true"
    static let received = "false"
}

// MARK: -

protocol SinglefoldXCTMatchable: XCTMatchable {
    static var text: String { get }
    static var expectedValue: String { get }
}

extension SinglefoldXCTMatchable where Self: Matcher {
    static var regex: Regex {
        return Regex(unsafePattern: "^\(text) \"(.*)\"( - (.*))?$")
    }

    var value: String { return captures[0] }
    var message: String? { return captures[2] }
    
    func print(to out: WritableStream) {
        printWrongValue(expected: Self.expectedValue, received: value, out: out)
    }
}

final class XCTNilMatch: Matcher, SinglefoldXCTMatchable {
    static let text = "XCTAssertNil failed:"
    static let expectedValue = "nil"
}

final class XCTNoThrowMatch: Matcher, SinglefoldXCTMatchable {
    static let text = "XCTAssertNoThrow failed: threw error"
    static let expectedValue = "no error"
}

// MARK: -

protocol TwofoldXCTMatchable: XCTMatchable {
    static var name: String { get }
    static var midText: String { get }
    static var expectationHeader: String { get }
}

extension TwofoldXCTMatchable where Self: Matcher {
    static var regex: Regex {
        return Regex(unsafePattern: "^\(name) failed: \\(\"(.*)\"\\) \(midText) \\(\"(.*)\"\\)( - (.*))?$")
    }

    var got: String { return captures[0] }
    var expected: String { return captures[1] }
    var message: String? { return captures[3] }
    
    func print(to out: WritableStream) {
        print(firstHeader: Self.expectationHeader, firstValue: expected, secondValue: got, out: out)
    }
}

final class XCTEqualMatch: Matcher, TwofoldXCTMatchable {
    static let name = "XCTAssertEqual"
    static let midText = "is not equal to"
    static let expectationHeader = "Expected"
}

final class XCTNotEqualMatch: Matcher, TwofoldXCTMatchable {
    static let name = "XCTAssertNotEqual"
    static let midText = "is equal to"
    static let expectationHeader = "Expected anything but"
}

final class XCTGreaterThanMatch: Matcher, TwofoldXCTMatchable {
    static let name = "XCTAssertGreaterThan"
    static let midText = "is not greater than"
    static let expectationHeader = "Expected value greater than"
}

final class XCTGreaterThanOrEqualMatch: Matcher, TwofoldXCTMatchable {
    static let name = "XCTAssertGreaterThanOrEqual"
    static let midText = "is less than"
    static let expectationHeader = "Expected value greater than or equal to"
}

final class XCTLessThanMatch: Matcher, TwofoldXCTMatchable {
    static let name = "XCTAssertLessThan"
    static let midText = "is not less than"
    static let expectationHeader = "Expected value less than"
}

final class XCTLessThanOrEqualMatch: Matcher, TwofoldXCTMatchable {
    static let name = "XCTAssertLessThanOrEqual"
    static let midText = "is greater than"
    static let expectationHeader = "Expected value less than or equal to"
}

// MARK: -

protocol AccuracyXCTMatchable: XCTMatchable {
    static var name: String { get }
    static var midText: String { get }
    static var firstHeader: String { get }
}

extension AccuracyXCTMatchable where Self: Matcher {
    static var regex: Regex {
        return Regex(unsafePattern: "^\(name) failed: \\(\"(.*)\"\\) \(midText) \\(\"(.*)\"\\) \\+\\/- \\(\"(.*)\"\\)( - (.*))?$")
    }
    
    var got: String { return captures[0] }
    var expected: String { return captures[1] }
    var accuracy: String { return captures[2] }
    var message: String? { return captures[4] }
    
    func print(to out: WritableStream) {
        print(firstHeader: Self.firstHeader, firstValue: expected + " (+/- \(accuracy))", secondValue: got, out: out)
    }
}

final class XCTEqualWithAccuracyMatch: Matcher, AccuracyXCTMatchable {
    static let name = "XCTAssertEqualWithAccuracy"
    static let midText = "is not equal to"
    static let firstHeader = "Expected"
}

final class XCTNotEqualWithAccuracyMatch: Matcher, AccuracyXCTMatchable {
    static let name = "XCTAssertNotEqualWithAccuracy"
    static let midText = "is equal to"
    static let firstHeader = "Expected anything but"
}

// MARK: -

final class XCTFailMatch: Matcher, XCTMatchable {
    static let regex = Regex("^failed( - (.*))?$")
    var message: String? { return captures[1] }
    
    func print(to out: WritableStream) {
        out <<< "\tXCTFail".red
    }
}
