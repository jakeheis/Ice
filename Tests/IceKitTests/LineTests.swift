//
//  LineTests.swift
//  TransformersTests
//
//  Created by Jake Heiser on 9/22/17.
//

import XCTest
import Regex
@testable import IceKit

class LineTests: XCTestCase {
    
    static var allTests = [
        ("testAssertionFailureLine", testAssertionFailureLine),
    ]
    
    func testAssertionFailureLine() {
        #if os(macOS)
        let text = "/Ice/Tests/CoreTests/ConfigTests.swift:52: error: -[CoreTests.ConfigTests testSet] : XCTAssertEqual failed: (\"value with a : is bad\") is not equal to (\"hello\") - "
        #else
        let text = "/Ice/Tests/CoreTests/ConfigTests.swift:52: error: ConfigTests.testSet : XCTAssertEqual failed: (\"value with a : is bad\") is not equal to (\"hello\") - "
        #endif
        let match = AssertionFailureLine.findMatch(in: text)
        XCTAssertEqual(match?.file, "/Ice/Tests/CoreTests/ConfigTests.swift")
        XCTAssertEqual(match?.lineNumber, 52)
        XCTAssertEqual(match?.assertion, "XCTAssertEqual failed: (\"value with a : is bad\") is not equal to (\"hello\") - ")
    }
    
}
