//
//  TestTests.swift
//  CLITests
//
//  Created by Jake Heiser on 9/14/17.
//

import XCTest

class TestTests: XCTestCase {
    
    func testStructure() {
        let result = Runner.execute(args: ["test"], sandbox: .lib)
        XCTAssertEqual(result.exitStatus, 0)
        
        result.stdout.assert { (v) in
            v.equals("Compile Lib (1 sources)")
            v.equals("Compile LibTests (1 sources)")
            v.matches("^Link \\./\\.build/.*/LibPackageTests$")
            v.empty()
            v.empty()
            v.done()
        }
        result.stderr.assert { (v) in
            v.empty()
            v.equals("LibPackageTests:")
            v.empty()
            v.equals(" RUNS  LibTests")
            v.equals(" PASS  LibTests")
            v.empty()
            v.equals("Tests:\t1 passed, 1 total")
            v.matches("^Time:\t[0-9\\.]+s$")
            v.empty()
            v.done()
        }
    }
    
    func testAssertions() {
        let result = Runner.execute(args: ["test"], sandbox: .fail)
        XCTAssertEqual(result.exitStatus, 1)
        
        result.stdout.assert { (v) in
            v.equals("Compile Fail (1 sources)")
            v.equals("Compile FailTests (1 sources)")
            v.matches("^Link \\./\\.build/.*/FailPackageTests$")
            v.empty()
            v.empty()
            v.done()
        }
        
        let assertionsArray = result.stderr.components(separatedBy: "\n\n").dropFirst(3)
        var assertions = assertionsArray.makeIterator()
        
        // XCTFail
        XCTAssertEqual(assertions.next(), "\tXCTFail")
        XCTAssertEqual(assertions.next(), "\tat Tests/FailTests/FailTests.swift:13")
        
        
        // XCTAssertEqual
        XCTAssertEqual(assertions.next(), """
        
        \tExpected:
        \they world
        \tReceived:
        \thello world
        """)
        XCTAssertEqual(assertions.next(), "\tat Tests/FailTests/FailTests.swift:17")
        
        // XCTAssertEqual with message
        XCTAssertEqual(assertions.next(), """
        
        \tExpected:
        \they world
        \tReceived:
        \thello world
        """)
        XCTAssertEqual(assertions.next(), "\tNote: The strings should be equal")
        XCTAssertEqual(assertions.next(), "\tat Tests/FailTests/FailTests.swift:18")
        
        // XCTAssertEqual multiline
        XCTAssertEqual(assertions.next(), """
        
        \tExpected:
        \tfirst line
        \tthird line
        \tReceived:
        \tfirst line
        \tsecondline
        """)
        XCTAssertEqual(assertions.next(), "\tat Tests/FailTests/FailTests.swift:20")
        
        // XCTAssertEqual multiline with message
        XCTAssertEqual(assertions.next(), """
        
        \tExpected:
        \tfirst line
        \tthird line
        \tReceived:
        \tfirst line
        \tsecondline
        """)
        XCTAssertEqual(assertions.next(), "\tNote: The multiline strings should be equal")
        XCTAssertEqual(assertions.next(), "\tat Tests/FailTests/FailTests.swift:21")
        
        // XCTAssertEqual with accuracy
        XCTAssertEqual(assertions.next(), """
        
        \tExpected:
        \t5.0 (+/- 0.5)
        \tReceived:
        \t4.0
        """)
        XCTAssertEqual(assertions.next(), "\tat Tests/FailTests/FailTests.swift:23")
        
        // XCTAssertNotEqual
        XCTAssertEqual(assertions.next(), """
        
        \tExpected anything but:
        \thello world
        \tReceived:
        \thello world
        """)
        XCTAssertEqual(assertions.next(), "\tat Tests/FailTests/FailTests.swift:25")
        
        // XCTAssertNotEqual mutiline
        XCTAssertEqual(assertions.next(), """
        
        \tExpected anything but:
        \tfirst line
        \tsecondline
        \tReceived:
        \tfirst line
        \tsecondline
        """)
        XCTAssertEqual(assertions.next(), "\tat Tests/FailTests/FailTests.swift:26")
        
        // XCTAssertNotEqual with accuracy
        XCTAssertEqual(assertions.next(), """
        
        \tExpected anything but:
        \t4.5 (+/- 0.5)
        \tReceived:
        \t4.0
        """)
        XCTAssertEqual(assertions.next(), "\tat Tests/FailTests/FailTests.swift:28")
        
        // XCTAssertNil
        XCTAssertEqual(assertions.next(), """
        
        \tExpected:
        \tnil
        \tReceived:
        \ta value
        """)
        XCTAssertEqual(assertions.next(), "\tNote: The value should be nil")
        XCTAssertEqual(assertions.next(), "\tat Tests/FailTests/FailTests.swift:32")
        
        // XCTAssertNotNil
        XCTAssertEqual(assertions.next(), """
        
        \tExpected:
        \tnon-nil
        \tReceived:
        \tnil
        """)
        XCTAssertEqual(assertions.next(), "\tNote: The value should not be nil")
        XCTAssertEqual(assertions.next(), "\tat Tests/FailTests/FailTests.swift:33")
        
        // XCTAssertGreaterThan
        XCTAssertEqual(assertions.next(), """
        
        \tExpected value greater than:
        \t4
        \tReceived:
        \t1
        """)
        XCTAssertEqual(assertions.next(), "\tNote: one should be greater than four")
        XCTAssertEqual(assertions.next(), "\tat Tests/FailTests/FailTests.swift:36")
        
        // XCTAssertLessThan
        XCTAssertEqual(assertions.next(), """
        
        \tExpected value less than:
        \t1
        \tReceived:
        \t4
        """)
        XCTAssertEqual(assertions.next(), "\tat Tests/FailTests/FailTests.swift:37")
        
        // XCTAssertGreaterThanOrEqual
        XCTAssertEqual(assertions.next(), """
        
        \tExpected value greater than or equal to:
        \t4
        \tReceived:
        \t1
        """)
        XCTAssertEqual(assertions.next(), "\tat Tests/FailTests/FailTests.swift:38")
        
        // XCTAssertLessThanOrEqual
        XCTAssertEqual(assertions.next(), """
        
        \tExpected value less than or equal to:
        \t1
        \tReceived:
        \t4
        """)
        XCTAssertEqual(assertions.next(), "\tat Tests/FailTests/FailTests.swift:39")
        
        // XCTAssertTrue
        XCTAssertEqual(assertions.next(), """
        
        \tExpected:
        \ttrue
        \tReceived:
        \tfalse
        """)
        XCTAssertEqual(assertions.next(), "\tat Tests/FailTests/FailTests.swift:42")
        
        // XCTAssertFalse
        XCTAssertEqual(assertions.next(), """
        
        \tExpected:
        \tfalse
        \tReceived:
        \ttrue
        """)
        XCTAssertEqual(assertions.next(), "\tat Tests/FailTests/FailTests.swift:43")
        
        // XCTAssert
        XCTAssertEqual(assertions.next(), """
        
        \tExpected:
        \ttrue
        \tReceived:
        \tfalse
        """)
        XCTAssertEqual(assertions.next(), "\tat Tests/FailTests/FailTests.swift:44")
        
        // XCTAssertThrowsError
        XCTAssertEqual(assertions.next(), """
        
        \tExpected:
        \terror thrown
        \tReceived:
        \tno error
        """)
        XCTAssertEqual(assertions.next(), "\tat Tests/FailTests/FailTests.swift:47")
        
        // XCTAssertNoThrow
        XCTAssertEqual(assertions.next(), """
        
        \tExpected:
        \tno error
        \tReceived:
        \tError Domain=ice Code=1 "(null)"
        """)
        XCTAssertEqual(assertions.next(), "\tat Tests/FailTests/FailTests.swift:48")
    }
    
}

postfix operator ++

@discardableResult
postfix func ++(int: inout Int) -> Int {
    let val = int
    int += 1
    return val
}
