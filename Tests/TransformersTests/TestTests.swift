//
//  TestTests.swift
//  TransformersTests
//
//  Created by Jake Heiser on 9/18/17.
//

import XCTest
@testable import Transformers

class TestTests: XCTestCase {
    
    override func setUp() {
        XCTestBegunResponse.hasPrinted = false
        TestsBegunResponse.mode = .all
    }
    
    func testPackageTestsBegun() {
        let test = TransformTest(Transformers.test)
        test.send(.err, """
        Test Suite 'IceTests.xctest' started
        """)
        test.expect(stdout: "", stderr: """
        
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
        test.expect(stdout: "", stderr: """
         RUNS  CLITests.AddTests
         PASS  CLITests.AddTests
        
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
        test.expect(stdout: "", stderr: """
         RUNS  CLITests.AddTests
         FAIL  CLITests.AddTests
        
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
        test.expect(stdout: "", stderr: """
         RUNS  CLITests.AddTests
         FAIL  CLITests.AddTests
        
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
        test.expect(stdout: "", stderr: """
         RUNS  CLITests.AddTests
         FAIL  CLITests.AddTests
        
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
        test.expect(stdout: "", stderr: """
         RUNS  CLITests.AddTests
         FAIL  CLITests.AddTests
        
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
        test.expect(stdout: "", stderr: """
         RUNS  CLITests.AddTests
         FAIL  CLITests.AddTests
        
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
        test.expect(stdout: "", stderr: """
         RUNS  CLITests.AddTests
         FAIL  CLITests.AddTests
        
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
        test.expect(stdout: "", stderr: """
         RUNS  CLITests.AddTests
         FAIL  CLITests.AddTests
        
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
        test.expect(stdout: "", stderr: """
         RUNS  CLITests.AddTests
         FAIL  CLITests.AddTests
        
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
        test.expect(stdout: "", stderr: """
         RUNS  CLITests.AddTests
         FAIL  CLITests.AddTests
        
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
        test.expect(stdout: "", stderr: """
         RUNS  CLITests.AddTests
         FAIL  CLITests.AddTests
        
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
        test.expect(stdout: "", stderr: """
         RUNS  CLITests.AddTests
         FAIL  CLITests.AddTests
        
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
        test.expect(stdout: "", stderr: """
         RUNS  CLITests.AddTests
         FAIL  CLITests.AddTests
        
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
        test.expect(stdout: "", stderr: """
         RUNS  CLITests.AddTests
         FAIL  CLITests.AddTests
        
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
        test.expect(stdout: "", stderr: """
         RUNS  CLITests.AddTests
         FAIL  CLITests.AddTests
        
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
        test.expect(stdout: "", stderr: """
         RUNS  CLITests.AddTests
         FAIL  CLITests.AddTests
        
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
        test.expect(stdout: "", stderr: """
         RUNS  CLITests.AddTests
         FAIL  CLITests.AddTests
        
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
        test.expect(stdout: "", stderr: """
         RUNS  CLITests.AddTests
         FAIL  CLITests.AddTests
        
         ● testBasicAdd

        \tExpected:
        \tfirst line
        \tthird line
        \tReceived:
        \tfirst line
        \tsecond line
        \t(end)

        \tat /Ice/Tests/IceTests/IceTests.swift:9
        
        
        """)
    }
    
    func testAllTests() {
        let test = TransformTest(Transformers.test)
        test.send(.err, """
        Test Suite 'All tests' started at 2017-09-18 21:46:20.406
        Test Suite 'IcePackageTests.xctest' started at 2017-09-18 21:46:20.406
        Test Suite 'OtherTests' started at 2017-09-18 21:46:20.406
        Test Case '-[IceTests.OtherTests testOne]' started.
        Test Case '-[IceTests.OtherTests testOne]' passed (0.080 seconds).
        Test Case '-[IceTests.OtherTests testTwo]' started.
        Test Case '-[IceTests.OtherTests testTwo]' passed (0.000 seconds).
        Test Suite 'OtherTests' passed at 2017-09-18 21:46:20.487.
             Executed 2 tests, with 0 failures (0 unexpected) in 0.080 (0.080) seconds
        Test Suite 'SomeTests' started at 2017-09-18 21:46:20.487
        Test Case '-[IceTests.SomeTests testOne]' started.
        Test Case '-[IceTests.SomeTests testOne]' passed (0.000 seconds).
        Test Case '-[IceTests.SomeTests testTwo]' started.
        """)
        test.send(.err, "/Ice/Tests/IceTests/IceTests.swift:11: error: -[IceTests.SomeTests testTwo] : failed - ")
        test.send(.err, "/Ice/Tests/IceTests/IceTests.swift:12: error: -[IceTests.SomeTests testTwo] : failed - ")
        test.send(.err, """
        Test Case '-[IceTests.SomeTests testTwo]' failed (0.001 seconds).
        Test Suite 'SomeTests' failed at 2017-09-18 21:46:20.488.
             Executed 2 tests, with 2 failures (0 unexpected) in 0.001 (0.001) seconds
        Test Suite 'IcePackageTests.xctest' failed at 2017-09-18 21:46:20.488.
             Executed 4 tests, with 2 failures (0 unexpected) in 0.082 (0.082) seconds
        Test Suite 'All tests' failed at 2017-09-18 21:46:20.488.
             Executed 4 tests, with 2 failures (0 unexpected) in 0.082 (0.082) seconds
        """)
        test.expect(stdout: "", stderr: """

        IcePackageTests:

         RUNS  IceTests.OtherTests
         PASS  IceTests.OtherTests
         RUNS  IceTests.SomeTests
         FAIL  IceTests.SomeTests

         ● testTwo

        \tXCTFail

        \tat /Ice/Tests/IceTests/IceTests.swift:11


        \tXCTFail

        \tat /Ice/Tests/IceTests/IceTests.swift:12
        
        
        Tests:\t1 failed, 3 passed, 4 total
        Time:\t0.082s
        
        
        """)
    }
    
    func testSelectedTests() {
        let test = TransformTest(Transformers.test)
        test.send(.err, """
        Test Suite 'Selected tests' started at 2017-09-18 21:53:48.479
        Test Suite 'IcePackageTests.xctest' started at 2017-09-18 21:53:48.479
        Test Suite 'OtherTests' started at 2017-09-18 21:53:48.480
        Test Case '-[IceTests.OtherTests testOne]' started.
        Test Case '-[IceTests.OtherTests testOne]' passed (0.079 seconds).
        Test Suite 'OtherTests' passed at 2017-09-18 21:53:48.558.
             Executed 1 test, with 0 failures (0 unexpected) in 0.079 (0.079) seconds
        Test Suite 'IcePackageTests.xctest' passed at 2017-09-18 21:53:48.559.
             Executed 1 test, with 0 failures (0 unexpected) in 0.079 (0.079) seconds
        Test Suite 'Selected tests' passed at 2017-09-18 21:53:48.559.
             Executed 1 test, with 0 failures (0 unexpected) in 0.079 (0.080) seconds
        Test Suite 'Selected tests' started at 2017-09-18 21:53:48.607
        Test Suite 'IcePackageTests.xctest' started at 2017-09-18 21:53:48.607
        Test Suite 'OtherTests' started at 2017-09-18 21:53:48.607
        Test Case '-[IceTests.OtherTests testTwo]' started.
        Test Case '-[IceTests.OtherTests testTwo]' passed (0.072 seconds).
        Test Suite 'OtherTests' passed at 2017-09-18 21:53:48.679.
             Executed 1 test, with 0 failures (0 unexpected) in 0.072 (0.072) seconds
        Test Suite 'IcePackageTests.xctest' passed at 2017-09-18 21:53:48.679.
             Executed 1 test, with 0 failures (0 unexpected) in 0.072 (0.072) seconds
        Test Suite 'Selected tests' passed at 2017-09-18 21:53:48.679.
             Executed 1 test, with 0 failures (0 unexpected) in 0.072 (0.073) seconds
        Test Suite 'Selected tests' started at 2017-09-18 21:53:48.729
        Test Suite 'IcePackageTests.xctest' started at 2017-09-18 21:53:48.729
        Test Suite 'SomeTests' started at 2017-09-18 21:53:48.729
        Test Case '-[IceTests.SomeTests testOne]' started.
        Test Case '-[IceTests.SomeTests testOne]' passed (0.082 seconds).
        Test Suite 'SomeTests' passed at 2017-09-18 21:53:48.811.
             Executed 1 test, with 0 failures (0 unexpected) in 0.082 (0.082) seconds
        Test Suite 'IcePackageTests.xctest' passed at 2017-09-18 21:53:48.811.
             Executed 1 test, with 0 failures (0 unexpected) in 0.082 (0.082) seconds
        Test Suite 'Selected tests' passed at 2017-09-18 21:53:48.811.
             Executed 1 test, with 0 failures (0 unexpected) in 0.082 (0.082) seconds
        Test Suite 'Selected tests' started at 2017-09-18 21:53:48.859
        Test Suite 'IcePackageTests.xctest' started at 2017-09-18 21:53:48.859
        Test Suite 'SomeTests' started at 2017-09-18 21:53:48.859
        Test Case '-[IceTests.SomeTests testTwo]' started.
        """)
        test.send(.err, "/Ice/Tests/IceTests/IceTests.swift:11: error: -[IceTests.SomeTests testTwo] : failed - ")
        test.send(.err, "/Ice/Tests/IceTests/IceTests.swift:12: error: -[IceTests.SomeTests testTwo] : failed - ")
        test.send(.err, """
        Test Case '-[IceTests.SomeTests testTwo]' failed (0.077 seconds).
        Test Suite 'SomeTests' failed at 2017-09-18 21:53:48.936.
             Executed 1 test, with 2 failures (0 unexpected) in 0.077 (0.077) seconds
        Test Suite 'IcePackageTests.xctest' failed at 2017-09-18 21:53:48.936.
             Executed 1 test, with 2 failures (0 unexpected) in 0.077 (0.077) seconds
        Test Suite 'Selected tests' failed at 2017-09-18 21:53:48.936.
             Executed 1 test, with 2 failures (0 unexpected) in 0.077 (0.077) seconds
        """)
        test.expect(stdout: "", stderr: """

        IcePackageTests:

         RUNS  IceTests.OtherTests/testOne
         PASS  IceTests.OtherTests/testOne

        Tests:\t1 passed, 1 total
        Time:\t0.080s

         RUNS  IceTests.OtherTests/testTwo
         PASS  IceTests.OtherTests/testTwo

        Tests:\t1 passed, 1 total
        Time:\t0.073s

         RUNS  IceTests.SomeTests/testOne
         PASS  IceTests.SomeTests/testOne

        Tests:\t1 passed, 1 total
        Time:\t0.082s

         RUNS  IceTests.SomeTests/testTwo
         FAIL  IceTests.SomeTests/testTwo

         ● testTwo

        \tXCTFail

        \tat /Ice/Tests/IceTests/IceTests.swift:11


        \tXCTFail

        \tat /Ice/Tests/IceTests/IceTests.swift:12


        Tests:\t1 failed, 1 total
        Time:\t0.077s
        
        
        """)
    }
    
}
