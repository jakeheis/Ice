//
//  TestLines.swift
//  Transformers
//
//  Created by Jake Heiser on 9/20/17.
//

import Exec
import Regex

final class AllTestsStartLine: Line {
    enum SuiteMode: String, Capturable {
        case all = "All tests"
        case selected = "Selected tests"
    }
    static let regex = Regex("^Test Suite '(All tests|Selected tests)' started")
    static let stream: StandardStream = .err
    
    var mode: SuiteMode { return captures[0] }
}

final class PackageTestsStartMatch: Line {
    static let regex = Regex("^Test Suite '(.*)\\.xctest' started")
    static let stream: StandardStream = .err
    
    var packageName: String { return captures[0] }
}

final class TestSuiteLine: Line {
    static let regex = Regex("^Test Suite '(.*)'")
    static let stream: StandardStream = .err
    
    var suiteName: String { return captures[0] }
}

final class TestCaseLine: Line {
    enum Status: String, Capturable {
        case started
        case passed
        case failed
    }
    static let regex = Regex("^Test Case '-\\[(.*)\\.(.*) (.*)\\]' (started|passed|failed)")
    static let stream: StandardStream = .err
    
    var targetName: String { return captures[0] }
    var suiteName: String { return captures[1] }
    var caseName: String { return captures[2] }
    var status: Status { return captures[3] }
}

final class FatalErrorLine: Line {
    static let regex = Regex("^fatal error: (.*)$")
    static let stream: StandardStream = .err
    
    var message: String { return captures[0] }
}

final class AssertionFailureLine: Line {
    static let regex = Regex("(.*):([0-9]+): error: .* : (.*)$")
    static let stream: StandardStream = .err
    
    var file: String { return captures[0] }
    var lineNumber: Int { return captures[1] }
    var assertion: String { return captures[2] }
}

final class AllTestsEndLine: Line {
    static let regex = Regex("Test Suite '(All tests|Selected tests|.*\\.xctest)' (passed|failed)")
    static let stream: StandardStream = .err
    
    var suite: String { return captures[0] }
}

final class TestCountLine: Line {
    static let regex = Regex("Executed ([0-9]+) tests?, with [0-9]* failures? .* \\(([\\.0-9]+)\\) seconds$")
    static let stream: StandardStream = .err
    
    var totalCount: Int { return captures[0] }
    var duration: String { return captures[1] }
}
