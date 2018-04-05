//
//  TestLines.swift
//  Transformers
//
//  Created by Jake Heiser on 9/20/17.
//

import Regex
import SwiftCLI

final class AllTestsStartLine: Matcher, Matchable {
    enum SuiteMode: String, ConvertibleFromString {
        case all = "All tests"
        case selected = "Selected tests"
    }
    static let regex = Regex("^Test Suite '(All tests|Selected tests)' started")
    var mode: SuiteMode { return captures[0] }
}

final class PackageTestsStartLine: Matcher, Matchable {
    static let regex = Regex("^Test Suite '(.*)\\.xctest' started")
    var packageName: String { return captures[0] }
}

final class TestSuiteLine: Matcher, Matchable {
    enum Status: String, ConvertibleFromString {
        case started
        case passed
        case failed
    }
    static let regex = Regex("^Test Suite '(.*)' (started|passed|failed)")
    var suiteName: String { return captures[0] }
    var status: Status { return captures[1] }
}

final class TestCaseLine: Matcher, Matchable {
    enum Status: String, ConvertibleFromString {
        case started
        case passed
        case failed
    }
    static let regex = Regex("^Test Case '-\\[([^ ]*)\\.([^ ]*) (.*)\\]' (started|passed|failed)")
    var targetName: String { return captures[0] }
    var suiteName: String { return captures[1] }
    var caseName: String { return captures[2] }
    var status: Status { return captures[3] }
}

final class FatalErrorLine: Matcher, Matchable {
    static let regex = Regex("^fatal error: (.*)$")
    var message: String { return captures[0] }
}

final class AssertionFailureLine: Matcher, Matchable {
    static let regex = Regex("^(.*):([0-9]+): error: -\\[\\w+\\.\\w+ \\w+\\] : (.*)$")
    var file: String { return captures[0] }
    var lineNumber: Int { return captures[1] }
    var assertion: String { return captures[2] }
}

final class AllTestsEndLine: Matcher, Matchable {
    static let regex = Regex("Test Suite '(All tests|Selected tests|.*\\.xctest)' (passed|failed)")
    var suite: String { return captures[0] }
}

final class TestCountLine: Matcher, Matchable {
    static let regex = Regex("Executed ([0-9]+) tests?, with [0-9]* failures? .* \\(([\\.0-9]+)\\) seconds$")
    var totalCount: Int { return captures[0] }
    var duration: String { return captures[1] }
}
