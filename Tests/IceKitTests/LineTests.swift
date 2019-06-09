//
//  LineTests.swift
//  TransformersTests
//
//  Created by Jake Heiser on 9/22/17.
//

@testable import IceKit
import XCTest

class LineTests: XCTestCase {
    
    func testAssertionFailureLine() {
        #if os(macOS)
        let text = "/Ice/Tests/CoreTests/ConfigTests.swift:52: error: -[CoreTests.ConfigTests testSet] : IceAssertEqual failed: (\"value with a : is bad\") is not equal to (\"hello\") - "
        #else
        let text = "/Ice/Tests/CoreTests/ConfigTests.swift:52: error: ConfigTests.testSet : IceAssertEqual failed: (\"value with a : is bad\") is not equal to (\"hello\") - "
        #endif
        let match = AssertionFailureLine.findMatch(in: text)
        IceAssertEqual(match?.file, "/Ice/Tests/CoreTests/ConfigTests.swift")
        IceAssertEqual(match?.lineNumber, 52)
        IceAssertEqual(match?.assertion, "IceAssertEqual failed: (\"value with a : is bad\") is not equal to (\"hello\") - ")
    }
    
}
