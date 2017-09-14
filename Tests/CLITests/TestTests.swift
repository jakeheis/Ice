//
//  TestTests.swift
//  CLITests
//
//  Created by Jake Heiser on 9/14/17.
//

import XCTest

class TestTests: XCTestCase {
    
    func testAssertions() {
        let result = Runner.execute(args: ["test"], sandbox: .fail)
        XCTAssertEqual(result.exitStatus, 1)
        
        let out = result.stdout.components(separatedBy: "\n")
        XCTAssertEqual(out.count, 5)
        XCTAssertEqual(out[0], "Compile Fail (1 sources)")
        XCTAssertEqual(out[1], "Compile FailTests (1 sources)")
        XCTAssertMatch(out[2], "^Link \\./\\.build/.*/FailPackageTests$")
        XCTAssertEqual(out[3], "")
        XCTAssertEqual(out[4], "")
        
        let assertions = result.stderr.components(separatedBy: "\n\n")
        
        var count = 3
        
        // XCTFail
        XCTAssertEqual(assertions[count++], "\tXCTFail")
        XCTAssertEqual(assertions[count++], "\tat Tests/FailTests/FailTests.swift:13")
        
        
        // XCTAssertEqual
        XCTAssertEqual(assertions[count++], """
        
        \tExpected:
        \they world
        \tReceived:
        \thello world
        """)
        XCTAssertEqual(assertions[count++], "\tat Tests/FailTests/FailTests.swift:17")
        
        // XCTAssertEqual with message
        XCTAssertEqual(assertions[count++], """
        
        \tExpected:
        \they world
        \tReceived:
        \thello world
        """)
        XCTAssertEqual(assertions[count++], "\tNote: The strings should be equal")
        XCTAssertEqual(assertions[count++], "\tat Tests/FailTests/FailTests.swift:18")
        
        // XCTAssertEqual multiline
        XCTAssertEqual(assertions[count++], """
        
        \tExpected:
        \tfirst line
        \tthird line
        \tReceived:
        \tfirst line
        \tsecondline
        """)
        XCTAssertEqual(assertions[count++], "\tat Tests/FailTests/FailTests.swift:20")
        
        // XCTAssertEqual multiline with message
        XCTAssertEqual(assertions[count++], """
        
        \tExpected:
        \tfirst line
        \tthird line
        \tReceived:
        \tfirst line
        \tsecondline
        """)
        XCTAssertEqual(assertions[count++], "\tNote: The multiline strings should be equal")
        XCTAssertEqual(assertions[count++], "\tat Tests/FailTests/FailTests.swift:21")
        
        // XCTAssertEqual with accuracy
        XCTAssertEqual(assertions[count++], """
        
        \tExpected:
        \t5.0 (+/- 0.5)
        \tReceived:
        \t4.0
        """)
        XCTAssertEqual(assertions[count++], "\tat Tests/FailTests/FailTests.swift:23")
        
        // XCTAssertNotEqual
        XCTAssertEqual(assertions[count++], """
        
        \tExpected anything but:
        \thello world
        \tReceived:
        \thello world
        """)
        XCTAssertEqual(assertions[count++], "\tat Tests/FailTests/FailTests.swift:25")
        
        // XCTAssertNotEqual mutiline
        XCTAssertEqual(assertions[count++], """
        
        \tExpected anything but:
        \tfirst line
        \tsecondline
        \tReceived:
        \tfirst line
        \tsecondline
        """)
        XCTAssertEqual(assertions[count++], "\tat Tests/FailTests/FailTests.swift:26")
        
        // XCTAssertNotEqual with accuracy
        XCTAssertEqual(assertions[count++], """
        
        \tExpected anything but:
        \t4.5 (+/- 0.5)
        \tReceived:
        \t4.0
        """)
        XCTAssertEqual(assertions[count++], "\tat Tests/FailTests/FailTests.swift:28")
        
        // XCTAssertNil
        XCTAssertEqual(assertions[count++], """
        
        \tExpected:
        \tnil
        \tReceived:
        \ta value
        """)
        XCTAssertEqual(assertions[count++], "\tNote: The value should be nil")
        XCTAssertEqual(assertions[count++], "\tat Tests/FailTests/FailTests.swift:32")
        
        // XCTAssertNotNil
        XCTAssertEqual(assertions[count++], """
        
        \tExpected:
        \tnon-nil
        \tReceived:
        \tnil
        """)
        XCTAssertEqual(assertions[count++], "\tNote: The value should not be nil")
        XCTAssertEqual(assertions[count++], "\tat Tests/FailTests/FailTests.swift:33")
        
        // XCTAssertGreaterThan
        XCTAssertEqual(assertions[count++], """
        
        \tExpected value greater than:
        \t4
        \tReceived:
        \t1
        """)
        XCTAssertEqual(assertions[count++], "\tNote: one should be greater than four")
        XCTAssertEqual(assertions[count++], "\tat Tests/FailTests/FailTests.swift:36")
        
        // XCTAssertLessThan
        XCTAssertEqual(assertions[count++], """
        
        \tExpected value less than:
        \t1
        \tReceived:
        \t4
        """)
        XCTAssertEqual(assertions[count++], "\tat Tests/FailTests/FailTests.swift:37")
        
        // XCTAssertGreaterThanOrEqual
        XCTAssertEqual(assertions[count++], """
        
        \tExpected value greater than or equal to:
        \t4
        \tReceived:
        \t1
        """)
        XCTAssertEqual(assertions[count++], "\tat Tests/FailTests/FailTests.swift:38")
        
        // XCTAssertLessThanOrEqual
        XCTAssertEqual(assertions[count++], """
        
        \tExpected value less than or equal to:
        \t1
        \tReceived:
        \t4
        """)
        XCTAssertEqual(assertions[count++], "\tat Tests/FailTests/FailTests.swift:39")
        
        // XCTAssertTrue
        XCTAssertEqual(assertions[count++], """
        
        \tExpected:
        \ttrue
        \tReceived:
        \tfalse
        """)
        XCTAssertEqual(assertions[count++], "\tat Tests/FailTests/FailTests.swift:42")
        
        // XCTAssertFalse
        XCTAssertEqual(assertions[count++], """
        
        \tExpected:
        \tfalse
        \tReceived:
        \ttrue
        """)
        XCTAssertEqual(assertions[count++], "\tat Tests/FailTests/FailTests.swift:43")
        
        // XCTAssert
        XCTAssertEqual(assertions[count++], """
        
        \tExpected:
        \ttrue
        \tReceived:
        \tfalse
        """)
        XCTAssertEqual(assertions[count++], "\tat Tests/FailTests/FailTests.swift:44")
        
        // XCTAssertThrowsError
        XCTAssertEqual(assertions[count++], """
        
        \tExpected:
        \terror thrown
        \tReceived:
        \tno error
        """)
        XCTAssertEqual(assertions[count++], "\tat Tests/FailTests/FailTests.swift:47")
        
        // XCTAssertNoThrow
        XCTAssertEqual(assertions[count++], """
        
        \tExpected:
        \tno error
        \tReceived:
        \tError Domain=ice Code=1 "(null)"
        """)
        XCTAssertEqual(assertions[count++], "\tat Tests/FailTests/FailTests.swift:48")
    }
    
}

postfix operator ++

@discardableResult
postfix func ++(int: inout Int) -> Int {
    let val = int
    int += 1
    return val
}
