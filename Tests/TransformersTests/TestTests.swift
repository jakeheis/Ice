//
//  TestTests.swift
//  TransformersTests
//
//  Created by Jake Heiser on 9/18/17.
//

import XCTest
import Transformers

class TestTests: XCTestCase {
    
    func testPackageTestsBegun() {
        let test = TransformTest(Transformers.test)
        test.send(.err, """
        Test Suite 'IceTests.xctest' started
        """)
        test.expect(stdout: "\n", stderr: """
        
        IceTests:
        
        
        """)
    }
    
    func testSuitePass() {
        let test = TransformTest(Transformers.test)
        test.send(.err, """
        Test Suite 'AddTests' started at 2017-09-18 10:18:14.163
        Test Case '-[CLITests.AddTests testBasicAdd]' started.
        Test Case '-[CLITests.AddTests testBasicAdd]' passed (0.716 seconds).
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect(stdout: "\n", stderr: """
         RUNS  AddTests
         PASS  AddTests
        
        """)
    }
    
    func testXCTFail() {
        let test = TransformTest(Transformers.test)
        test.send(.err, """
        Test Suite 'AddTests' started at 2017-09-18 10:18:14.163
        Test Case '-[CLITests.AddTests testBasicAdd]' started.
        """)
        test.send(.err, "/Ice/Tests/IceTests/IceTests.swift:9: error: -[IceTests.IceTests testExample] : failed - ")
        test.send(.err, """
        Test Case '-[CLITests.AddTests testBasicAdd]' failed (0.716 seconds).
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect(stdout: "\n", stderr: """
         RUNS  AddTests
         FAIL  AddTests
        
         ● testBasicAdd

        \tXCTFail

        \tat /Ice/Tests/IceTests/IceTests.swift:9
        
        
        """)
    }
    
    func testXCTEquals() {
        let test = TransformTest(Transformers.test)
        test.send(.err, """
        Test Suite 'AddTests' started at 2017-09-18 10:18:14.163
        Test Case '-[CLITests.AddTests testBasicAdd]' started.
        """)
        test.send(.err, "/Ice/Tests/IceTests/IceTests.swift:9: error: -[IceTests.IceTests testExample] : XCTAssertEqual failed: (\"Hello, World!\") is not equal to (\"Hello, Worldddd!\") - ")
        test.send(.err, """
        Test Case '-[CLITests.AddTests testBasicAdd]' failed (0.716 seconds).
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect(stdout: "\n", stderr: """
         RUNS  AddTests
         FAIL  AddTests
        
         ● testBasicAdd

        \tExpected:
        \tHello, Worldddd!
        \tReceived:
        \tHello, World!

        \tat /Ice/Tests/IceTests/IceTests.swift:9
        
        
        """)
    }
    
    func testXCTEqualWithAccuracy() {
        let test = TransformTest(Transformers.test)
        test.send(.err, """
        Test Suite 'AddTests' started at 2017-09-18 10:18:14.163
        Test Case '-[CLITests.AddTests testBasicAdd]' started.
        """)
        test.send(.err, "/Ice/Tests/IceTests/IceTests.swift:23: error: -[IceTests.IceTests testExample] : XCTAssertEqualWithAccuracy failed: (\"4.0\") is not equal to (\"5.0\") +/- (\"0.5\") - ")
        test.send(.err, """
        Test Case '-[CLITests.AddTests testBasicAdd]' failed (0.716 seconds).
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect(stdout: "\n", stderr: """
         RUNS  AddTests
         FAIL  AddTests
        
         ● testBasicAdd

        \tExpected:
        \t5.0 (+/- 0.5)
        \tReceived:
        \t4.0

        \tat /Ice/Tests/IceTests/IceTests.swift:23
        
        
        """)
    }
    
    func testXCTNotEquals() {
        let test = TransformTest(Transformers.test)
        test.send(.err, """
        Test Suite 'AddTests' started at 2017-09-18 10:18:14.163
        Test Case '-[CLITests.AddTests testBasicAdd]' started.
        """)
        test.send(.err, "/Ice/Tests/IceTests/IceTests.swift:9: error: -[IceTests.IceTests testExample] : XCTAssertNotEqual failed: (\"hello world\") is equal to (\"hello world\") - ")
        test.send(.err, """
        Test Case '-[CLITests.AddTests testBasicAdd]' failed (0.716 seconds).
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect(stdout: "\n", stderr: """
         RUNS  AddTests
         FAIL  AddTests
        
         ● testBasicAdd

        \tExpected anything but:
        \thello world
        \tReceived:
        \thello world

        \tat /Ice/Tests/IceTests/IceTests.swift:9
        
        
        """)
    }
    
    func testXCTNotEqualWithAccuracy() {
        let test = TransformTest(Transformers.test)
        test.send(.err, """
        Test Suite 'AddTests' started at 2017-09-18 10:18:14.163
        Test Case '-[CLITests.AddTests testBasicAdd]' started.
        """)
        test.send(.err, "/Ice/Tests/IceTests/IceTests.swift:23: error: -[IceTests.IceTests testExample] : XCTAssertNotEqualWithAccuracy failed: (\"4.0\") is equal to (\"4.5\") +/- (\"0.5\") - ")
        test.send(.err, """
        Test Case '-[CLITests.AddTests testBasicAdd]' failed (0.716 seconds).
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect(stdout: "\n", stderr: """
         RUNS  AddTests
         FAIL  AddTests
        
         ● testBasicAdd

        \tExpected anything but:
        \t4.5 (+/- 0.5)
        \tReceived:
        \t4.0

        \tat /Ice/Tests/IceTests/IceTests.swift:23
        
        
        """)
    }
    
    func 
        testXCTNil() {
        let test = TransformTest(Transformers.test)
        test.send(.err, """
        Test Suite 'AddTests' started at 2017-09-18 10:18:14.163
        Test Case '-[CLITests.AddTests testBasicAdd]' started.
        """)
        test.send(.err, "/Ice/Tests/IceTests/IceTests.swift:9: error: -[FailTests.FailTests testAssertions] : XCTAssertNil failed: \"hello world\" - The value should be nil")
        test.send(.err, """
        Test Case '-[CLITests.AddTests testBasicAdd]' failed (0.716 seconds).
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect(stdout: "\n", stderr: """
         RUNS  AddTests
         FAIL  AddTests
        
         ● testBasicAdd

        \tExpected:
        \tnil
        \tReceived:
        \thello world

        \tNote: The value should be nil

        \tat /Ice/Tests/IceTests/IceTests.swift:9
        
        
        """)
    }
    
    func testXCTNotNil() {
        let test = TransformTest(Transformers.test)
        test.send(.err, """
        Test Suite 'AddTests' started at 2017-09-18 10:18:14.163
        Test Case '-[CLITests.AddTests testBasicAdd]' started.
        """)
        test.send(.err, "/Ice/Tests/IceTests/IceTests.swift:9: error: -[FailTests.FailTests testAssertions] : XCTAssertNotNil failed - The value should not be nil")
        test.send(.err, """
        Test Case '-[CLITests.AddTests testBasicAdd]' failed (0.716 seconds).
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect(stdout: "\n", stderr: """
         RUNS  AddTests
         FAIL  AddTests
        
         ● testBasicAdd

        \tExpected:
        \tnon-nil
        \tReceived:
        \tnil

        \tNote: The value should not be nil

        \tat /Ice/Tests/IceTests/IceTests.swift:9
        
        
        """)
    }
    
    func testXCTThrow() {
        let test = TransformTest(Transformers.test)
        test.send(.err, """
        Test Suite 'AddTests' started at 2017-09-18 10:18:14.163
        Test Case '-[CLITests.AddTests testBasicAdd]' started.
        """)
        test.send(.err, "/Ice/Tests/IceTests/IceTests.swift:9: error: -[FailTests.FailTests testAssertions] : XCTAssertThrowsError failed: did not throw an error - ")
        test.send(.err, """
        Test Case '-[CLITests.AddTests testBasicAdd]' failed (0.716 seconds).
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect(stdout: "\n", stderr: """
         RUNS  AddTests
         FAIL  AddTests
        
         ● testBasicAdd

        \tExpected:
        \terror thrown
        \tReceived:
        \tno error

        \tat /Ice/Tests/IceTests/IceTests.swift:9
        
        
        """)
    }
    
    func testXCTNoThrow() {
        let test = TransformTest(Transformers.test)
        test.send(.err, """
        Test Suite 'AddTests' started at 2017-09-18 10:18:14.163
        Test Case '-[CLITests.AddTests testBasicAdd]' started.
        """)
        test.send(.err, "/Ice/Tests/IceTests/IceTests.swift:9: error: -[FailTests.FailTests testAssertions] : XCTAssertNoThrow failed: threw error \"Error Domain=ice Code=1 \"(null)\"\" - ")
        test.send(.err, """
        Test Case '-[CLITests.AddTests testBasicAdd]' failed (0.716 seconds).
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect(stdout: "\n", stderr: """
         RUNS  AddTests
         FAIL  AddTests
        
         ● testBasicAdd

        \tExpected:
        \tno error
        \tReceived:
        \tError Domain=ice Code=1 "(null)"

        \tat /Ice/Tests/IceTests/IceTests.swift:9
        
        
        """)
    }
    
    func testXCTAssert() {
        let test = TransformTest(Transformers.test)
        test.send(.err, """
        Test Suite 'AddTests' started at 2017-09-18 10:18:14.163
        Test Case '-[CLITests.AddTests testBasicAdd]' started.
        """)
        test.send(.err, "/Ice/Tests/IceTests/IceTests.swift:9: error: -[FailTests.FailTests testAssertions] : XCTAssert failed - ")
        test.send(.err, """
        Test Case '-[CLITests.AddTests testBasicAdd]' failed (0.716 seconds).
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect(stdout: "\n", stderr: """
         RUNS  AddTests
         FAIL  AddTests
        
         ● testBasicAdd

        \tExpected:
        \ttrue
        \tReceived:
        \tfalse

        \tat /Ice/Tests/IceTests/IceTests.swift:9
        
        
        """)
    }
    
    func testXCTTrue() {
        let test = TransformTest(Transformers.test)
        test.send(.err, """
        Test Suite 'AddTests' started at 2017-09-18 10:18:14.163
        Test Case '-[CLITests.AddTests testBasicAdd]' started.
        """)
        test.send(.err, "/Ice/Tests/IceTests/IceTests.swift:9: error: -[FailTests.FailTests testAssertions] : XCTAssertTrue failed - ")
        test.send(.err, """
        Test Case '-[CLITests.AddTests testBasicAdd]' failed (0.716 seconds).
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect(stdout: "\n", stderr: """
         RUNS  AddTests
         FAIL  AddTests
        
         ● testBasicAdd

        \tExpected:
        \ttrue
        \tReceived:
        \tfalse

        \tat /Ice/Tests/IceTests/IceTests.swift:9
        
        
        """)
    }
    
    func testXCTFalse() {
        let test = TransformTest(Transformers.test)
        test.send(.err, """
        Test Suite 'AddTests' started at 2017-09-18 10:18:14.163
        Test Case '-[CLITests.AddTests testBasicAdd]' started.
        """)
        test.send(.err, "/Ice/Tests/IceTests/IceTests.swift:9: error: -[FailTests.FailTests testAssertions] : XCTAssertFalse failed - ")
        test.send(.err, """
        Test Case '-[CLITests.AddTests testBasicAdd]' failed (0.716 seconds).
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect(stdout: "\n", stderr: """
         RUNS  AddTests
         FAIL  AddTests
        
         ● testBasicAdd

        \tExpected:
        \tfalse
        \tReceived:
        \ttrue

        \tat /Ice/Tests/IceTests/IceTests.swift:9
        
        
        """)
    }
    
    func testXCTGreaterThan() {
        let test = TransformTest(Transformers.test)
        test.send(.err, """
        Test Suite 'AddTests' started at 2017-09-18 10:18:14.163
        Test Case '-[CLITests.AddTests testBasicAdd]' started.
        """)
        test.send(.err, "/Ice/Tests/IceTests/IceTests.swift:9: error: -[IceTests.IceTests testExample] : XCTAssertGreaterThan failed: (\"1\") is not greater than (\"4\") - one should be greater than four")
        test.send(.err, """
        Test Case '-[CLITests.AddTests testBasicAdd]' failed (0.716 seconds).
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect(stdout: "\n", stderr: """
         RUNS  AddTests
         FAIL  AddTests
        
         ● testBasicAdd

        \tExpected value greater than:
        \t4
        \tReceived:
        \t1

        \tNote: one should be greater than four

        \tat /Ice/Tests/IceTests/IceTests.swift:9
        
        
        """)
    }
    
    func testXCTGreaterThanOrEqual() {
        let test = TransformTest(Transformers.test)
        test.send(.err, """
        Test Suite 'AddTests' started at 2017-09-18 10:18:14.163
        Test Case '-[CLITests.AddTests testBasicAdd]' started.
        """)
        test.send(.err, "/Ice/Tests/IceTests/IceTests.swift:9: error: -[IceTests.IceTests testExample] : XCTAssertGreaterThanOrEqual failed: (\"1\") is less than (\"4\") - one should be greater than or equal to four")
        test.send(.err, """
        Test Case '-[CLITests.AddTests testBasicAdd]' failed (0.716 seconds).
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect(stdout: "\n", stderr: """
         RUNS  AddTests
         FAIL  AddTests
        
         ● testBasicAdd

        \tExpected value greater than or equal to:
        \t4
        \tReceived:
        \t1

        \tNote: one should be greater than or equal to four

        \tat /Ice/Tests/IceTests/IceTests.swift:9
        
        
        """)
    }
    
    func testXCTLessThan() {
        let test = TransformTest(Transformers.test)
        test.send(.err, """
        Test Suite 'AddTests' started at 2017-09-18 10:18:14.163
        Test Case '-[CLITests.AddTests testBasicAdd]' started.
        """)
        test.send(.err, "/Ice/Tests/IceTests/IceTests.swift:9: error: -[IceTests.IceTests testExample] : XCTAssertLessThan failed: (\"4\") is not less than (\"1\") - ")
        test.send(.err, """
        Test Case '-[CLITests.AddTests testBasicAdd]' failed (0.716 seconds).
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect(stdout: "\n", stderr: """
         RUNS  AddTests
         FAIL  AddTests
        
         ● testBasicAdd

        \tExpected value less than:
        \t1
        \tReceived:
        \t4

        \tat /Ice/Tests/IceTests/IceTests.swift:9
        
        
        """)
    }
    
    func testXCTLessThanOrEqual() {
        let test = TransformTest(Transformers.test)
        test.send(.err, """
        Test Suite 'AddTests' started at 2017-09-18 10:18:14.163
        Test Case '-[CLITests.AddTests testBasicAdd]' started.
        """)
        test.send(.err, "/Ice/Tests/IceTests/IceTests.swift:9: error: -[IceTests.IceTests testExample] : XCTAssertLessThanOrEqual failed: (\"4\") is greater than (\"1\") - ")
        test.send(.err, """
        Test Case '-[CLITests.AddTests testBasicAdd]' failed (0.716 seconds).
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect(stdout: "\n", stderr: """
         RUNS  AddTests
         FAIL  AddTests
        
         ● testBasicAdd

        \tExpected value less than or equal to:
        \t1
        \tReceived:
        \t4

        \tat /Ice/Tests/IceTests/IceTests.swift:9
        
        
        """)
    }
    
    func testMultilineEquality() {
        let test = TransformTest(Transformers.test)
        test.send(.err, """
        Test Suite 'AddTests' started at 2017-09-18 10:18:14.163
        Test Case '-[CLITests.AddTests testBasicAdd]' started.
        /Ice/Tests/IceTests/IceTests.swift:9: error: -[IceTests.IceTests testExample] : XCTAssertEqual failed: ("first line
        second line") is not equal to ("first line
        """)
        test.send(.err, "third line\") - ")
        test.send(.err, """
        Test Case '-[CLITests.AddTests testBasicAdd]' failed (0.716 seconds).
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect(stdout: "\n", stderr: """
         RUNS  AddTests
         FAIL  AddTests
        
         ● testBasicAdd

        \tExpected:
        \tfirst line
        \tthird line
        \tReceived:
        \tfirst line
        \tsecond line

        \tat /Ice/Tests/IceTests/IceTests.swift:9
        
        
        """)
    }
    
}
