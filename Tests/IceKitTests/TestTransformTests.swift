//
//  TestTransformTests.swift
//  TransformersTests
//
//  Created by Jake Heiser on 9/18/17.
//

import XCTest
@testable import IceKit

class TestTransformTests: XCTestCase {
    
    static var allTests = [
        ("testSuitePass", testSuitePass),
        ("testXCTFail", testXCTFail),
        ("testXCTEquals", testXCTEquals),
        ("testXCTEqualWithAccuracy", testXCTEqualWithAccuracy),
        ("testXCTNotEquals", testXCTNotEquals),
        ("testXCTNotEqualWithAccuracy", testXCTNotEqualWithAccuracy),
        ("testXCTNil", testXCTNil),
        ("testXCTNotNil", testXCTNotNil),
        ("testXCTThrow", testXCTThrow),
        ("testXCTNoThrow", testXCTNoThrow),
        ("testXCTAssert", testXCTAssert),
        ("testXCTTrue", testXCTTrue),
        ("testXCTFalse", testXCTFalse),
        ("testXCTGreaterThan", testXCTGreaterThan),
        ("testXCTGreaterThanOrEqual", testXCTGreaterThanOrEqual),
        ("testXCTLessThan", testXCTLessThan),
        ("testXCTLessThanOrEqual", testXCTLessThanOrEqual),
        ("testMultilineEquality", testMultilineEquality),
        ("testAllTests", testAllTests),
        ("testSelectedTests", testSelectedTests),
        ("testInterleavedOutput", testInterleavedOutput),
        ("testNoTests", testNoTests),
        ("testNoFilterMatch", testNoFilterMatch),
    ]
    
    func testSuitePass() {
        let test = createTest(TestSuite(mode: .all))
        test.send("""
        Test Suite 'AddTests' started at 2017-09-18 10:18:14.163
        Test Case '-[CLITests.AddTests testBasicAdd]' started.
        Test Case '-[CLITests.AddTests testBasicAdd]' passed (0.716 seconds).
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect("""
         RUNS  CLITests.AddTests
         PASS  CLITests.AddTests
        
        """)
    }
    
    func testXCTFail() {
        let test = createTest(TestSuite(mode: .all))
        test.send("""
        Test Suite 'AddTests' started at 2017-09-18 10:18:14.163
        Test Case '-[CLITests.AddTests testBasicAdd]' started.
        """)
        test.send("/IceIce/Tests/IceTests/IceTests.swift:9: error: -[IceTests.IceTests testExample] : failed - ")
        test.send("""
        Test Case '-[CLITests.AddTests testBasicAdd]' failed (0.716 seconds).
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect("""
         RUNS  CLITests.AddTests
         FAIL  CLITests.AddTests
        
         ● testBasicAdd

        \tXCTFail

        \tat /IceIce/Tests/IceTests/IceTests.swift:9
        
        
        """)
    }
    
    func testXCTEquals() {
        let test = createTest(TestSuite(mode: .all))
        test.send("""
        Test Suite 'AddTests' started at 2017-09-18 10:18:14.163
        Test Case '-[CLITests.AddTests testBasicAdd]' started.
        """)
        test.send("/IceIce/Tests/IceTests/IceTests.swift:9: error: -[IceTests.IceTests testExample] : XCTAssertEqual failed: (\"Hello, World!\") is not equal to (\"Hello, Worldddd!\") - ")
        test.send("""
        Test Case '-[CLITests.AddTests testBasicAdd]' failed (0.716 seconds).
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect("""
         RUNS  CLITests.AddTests
         FAIL  CLITests.AddTests
        
         ● testBasicAdd

        \tExpected:
        \tHello, Worldddd!
        \tReceived:
        \tHello, World!

        \tat /IceIce/Tests/IceTests/IceTests.swift:9
        
        
        """)
    }
    
    func testXCTEqualWithAccuracy() {
        let test = createTest(TestSuite(mode: .all))
        test.send("""
        Test Suite 'AddTests' started at 2017-09-18 10:18:14.163
        Test Case '-[CLITests.AddTests testBasicAdd]' started.
        """)
        test.send("/IceIce/Tests/IceTests/IceTests.swift:23: error: -[IceTests.IceTests testExample] : XCTAssertEqualWithAccuracy failed: (\"4.0\") is not equal to (\"5.0\") +/- (\"0.5\") - ")
        test.send("""
        Test Case '-[CLITests.AddTests testBasicAdd]' failed (0.716 seconds).
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect("""
         RUNS  CLITests.AddTests
         FAIL  CLITests.AddTests
        
         ● testBasicAdd

        \tExpected:
        \t5.0 (+/- 0.5)
        \tReceived:
        \t4.0

        \tat /IceIce/Tests/IceTests/IceTests.swift:23
        
        
        """)
    }
    
    func testXCTNotEquals() {
        let test = createTest(TestSuite(mode: .all))
        test.send("""
        Test Suite 'AddTests' started at 2017-09-18 10:18:14.163
        Test Case '-[CLITests.AddTests testBasicAdd]' started.
        """)
        test.send("/IceIce/Tests/IceTests/IceTests.swift:9: error: -[IceTests.IceTests testExample] : XCTAssertNotEqual failed: (\"hello world\") is equal to (\"hello world\") - ")
        test.send("""
        Test Case '-[CLITests.AddTests testBasicAdd]' failed (0.716 seconds).
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect("""
         RUNS  CLITests.AddTests
         FAIL  CLITests.AddTests
        
         ● testBasicAdd

        \tExpected anything but:
        \thello world
        \tReceived:
        \thello world

        \tat /IceIce/Tests/IceTests/IceTests.swift:9
        
        
        """)
    }
    
    func testXCTNotEqualWithAccuracy() {
        let test = createTest(TestSuite(mode: .all))
        test.send("""
        Test Suite 'AddTests' started at 2017-09-18 10:18:14.163
        Test Case '-[CLITests.AddTests testBasicAdd]' started.
        """)
        test.send("/IceIce/Tests/IceTests/IceTests.swift:23: error: -[IceTests.IceTests testExample] : XCTAssertNotEqualWithAccuracy failed: (\"4.0\") is equal to (\"4.5\") +/- (\"0.5\") - ")
        test.send("""
        Test Case '-[CLITests.AddTests testBasicAdd]' failed (0.716 seconds).
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect("""
         RUNS  CLITests.AddTests
         FAIL  CLITests.AddTests
        
         ● testBasicAdd

        \tExpected anything but:
        \t4.5 (+/- 0.5)
        \tReceived:
        \t4.0

        \tat /IceIce/Tests/IceTests/IceTests.swift:23
        
        
        """)
    }
    
    func testXCTNil() {
        let test = createTest(TestSuite(mode: .all))
        test.send("""
        Test Suite 'AddTests' started at 2017-09-18 10:18:14.163
        Test Case '-[CLITests.AddTests testBasicAdd]' started.
        """)
        test.send("/IceIce/Tests/IceTests/IceTests.swift:9: error: -[FailTests.FailTests testAssertions] : XCTAssertNil failed: \"hello world\" - The value should be nil")
        test.send("""
        Test Case '-[CLITests.AddTests testBasicAdd]' failed (0.716 seconds).
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect("""
         RUNS  CLITests.AddTests
         FAIL  CLITests.AddTests
        
         ● testBasicAdd

        \tExpected:
        \tnil
        \tReceived:
        \thello world

        \tNote: The value should be nil

        \tat /IceIce/Tests/IceTests/IceTests.swift:9
        
        
        """)
    }
    
    func testXCTNotNil() {
        let test = createTest(TestSuite(mode: .all))
        test.send("""
        Test Suite 'AddTests' started at 2017-09-18 10:18:14.163
        Test Case '-[CLITests.AddTests testBasicAdd]' started.
        """)
        test.send("/IceIce/Tests/IceTests/IceTests.swift:9: error: -[FailTests.FailTests testAssertions] : XCTAssertNotNil failed - The value should not be nil")
        test.send("""
        Test Case '-[CLITests.AddTests testBasicAdd]' failed (0.716 seconds).
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect("""
         RUNS  CLITests.AddTests
         FAIL  CLITests.AddTests
        
         ● testBasicAdd

        \tExpected:
        \tnon-nil
        \tReceived:
        \tnil

        \tNote: The value should not be nil

        \tat /IceIce/Tests/IceTests/IceTests.swift:9
        
        
        """)
    }
    
    func testXCTThrow() {
        let test = createTest(TestSuite(mode: .all))
        test.send("""
        Test Suite 'AddTests' started at 2017-09-18 10:18:14.163
        Test Case '-[CLITests.AddTests testBasicAdd]' started.
        """)
        test.send("/IceIce/Tests/IceTests/IceTests.swift:9: error: -[FailTests.FailTests testAssertions] : XCTAssertThrowsError failed: did not throw an error - ")
        test.send("""
        Test Case '-[CLITests.AddTests testBasicAdd]' failed (0.716 seconds).
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect("""
         RUNS  CLITests.AddTests
         FAIL  CLITests.AddTests
        
         ● testBasicAdd

        \tExpected:
        \terror thrown
        \tReceived:
        \tno error

        \tat /IceIce/Tests/IceTests/IceTests.swift:9
        
        
        """)
    }
    
    func testXCTNoThrow() {
        let test = createTest(TestSuite(mode: .all))
        test.send("""
        Test Suite 'AddTests' started at 2017-09-18 10:18:14.163
        Test Case '-[CLITests.AddTests testBasicAdd]' started.
        """)
        test.send("/IceIce/Tests/IceTests/IceTests.swift:9: error: -[FailTests.FailTests testAssertions] : XCTAssertNoThrow failed: threw error \"Error Domain=ice Code=1 \"(null)\"\" - ")
        test.send("""
        Test Case '-[CLITests.AddTests testBasicAdd]' failed (0.716 seconds).
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect("""
         RUNS  CLITests.AddTests
         FAIL  CLITests.AddTests
        
         ● testBasicAdd

        \tExpected:
        \tno error
        \tReceived:
        \tError Domain=ice Code=1 "(null)"

        \tat /IceIce/Tests/IceTests/IceTests.swift:9
        
        
        """)
    }
    
    func testXCTAssert() {
        let test = createTest(TestSuite(mode: .all))
        test.send("""
        Test Suite 'AddTests' started at 2017-09-18 10:18:14.163
        Test Case '-[CLITests.AddTests testBasicAdd]' started.
        """)
        test.send("/IceIce/Tests/IceTests/IceTests.swift:9: error: -[FailTests.FailTests testAssertions] : XCTAssert failed - ")
        test.send("""
        Test Case '-[CLITests.AddTests testBasicAdd]' failed (0.716 seconds).
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect("""
         RUNS  CLITests.AddTests
         FAIL  CLITests.AddTests
        
         ● testBasicAdd

        \tExpected:
        \ttrue
        \tReceived:
        \tfalse

        \tat /IceIce/Tests/IceTests/IceTests.swift:9
        
        
        """)
    }
    
    func testXCTTrue() {
        let test = createTest(TestSuite(mode: .all))
        test.send("""
        Test Suite 'AddTests' started at 2017-09-18 10:18:14.163
        Test Case '-[CLITests.AddTests testBasicAdd]' started.
        """)
        test.send("/IceIce/Tests/IceTests/IceTests.swift:9: error: -[FailTests.FailTests testAssertions] : XCTAssertTrue failed - ")
        test.send("""
        Test Case '-[CLITests.AddTests testBasicAdd]' failed (0.716 seconds).
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect("""
         RUNS  CLITests.AddTests
         FAIL  CLITests.AddTests
        
         ● testBasicAdd

        \tExpected:
        \ttrue
        \tReceived:
        \tfalse

        \tat /IceIce/Tests/IceTests/IceTests.swift:9
        
        
        """)
    }
    
    func testXCTFalse() {
        let test = createTest(TestSuite(mode: .all))
        test.send("""
        Test Suite 'AddTests' started at 2017-09-18 10:18:14.163
        Test Case '-[CLITests.AddTests testBasicAdd]' started.
        """)
        test.send("/IceIce/Tests/IceTests/IceTests.swift:9: error: -[FailTests.FailTests testAssertions] : XCTAssertFalse failed - ")
        test.send("""
        Test Case '-[CLITests.AddTests testBasicAdd]' failed (0.716 seconds).
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect("""
         RUNS  CLITests.AddTests
         FAIL  CLITests.AddTests
        
         ● testBasicAdd

        \tExpected:
        \tfalse
        \tReceived:
        \ttrue

        \tat /IceIce/Tests/IceTests/IceTests.swift:9
        
        
        """)
    }
    
    func testXCTGreaterThan() {
        let test = createTest(TestSuite(mode: .all))
        test.send("""
        Test Suite 'AddTests' started at 2017-09-18 10:18:14.163
        Test Case '-[CLITests.AddTests testBasicAdd]' started.
        """)
        test.send("/IceIce/Tests/IceTests/IceTests.swift:9: error: -[IceTests.IceTests testExample] : XCTAssertGreaterThan failed: (\"1\") is not greater than (\"4\") - one should be greater than four")
        test.send("""
        Test Case '-[CLITests.AddTests testBasicAdd]' failed (0.716 seconds).
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect("""
         RUNS  CLITests.AddTests
         FAIL  CLITests.AddTests
        
         ● testBasicAdd

        \tExpected value greater than:
        \t4
        \tReceived:
        \t1

        \tNote: one should be greater than four

        \tat /IceIce/Tests/IceTests/IceTests.swift:9
        
        
        """)
    }
    
    func testXCTGreaterThanOrEqual() {
        let test = createTest(TestSuite(mode: .all))
        test.send("""
        Test Suite 'AddTests' started at 2017-09-18 10:18:14.163
        Test Case '-[CLITests.AddTests testBasicAdd]' started.
        """)
        test.send("/IceIce/Tests/IceTests/IceTests.swift:9: error: -[IceTests.IceTests testExample] : XCTAssertGreaterThanOrEqual failed: (\"1\") is less than (\"4\") - one should be greater than or equal to four")
        test.send("""
        Test Case '-[CLITests.AddTests testBasicAdd]' failed (0.716 seconds).
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect("""
         RUNS  CLITests.AddTests
         FAIL  CLITests.AddTests
        
         ● testBasicAdd

        \tExpected value greater than or equal to:
        \t4
        \tReceived:
        \t1

        \tNote: one should be greater than or equal to four

        \tat /IceIce/Tests/IceTests/IceTests.swift:9
        
        
        """)
    }
    
    func testXCTLessThan() {
        let test = createTest(TestSuite(mode: .all))
        test.send("""
        Test Suite 'AddTests' started at 2017-09-18 10:18:14.163
        Test Case '-[CLITests.AddTests testBasicAdd]' started.
        """)
        test.send("/IceIce/Tests/IceTests/IceTests.swift:9: error: -[IceTests.IceTests testExample] : XCTAssertLessThan failed: (\"4\") is not less than (\"1\") - ")
        test.send("""
        Test Case '-[CLITests.AddTests testBasicAdd]' failed (0.716 seconds).
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect("""
         RUNS  CLITests.AddTests
         FAIL  CLITests.AddTests
        
         ● testBasicAdd

        \tExpected value less than:
        \t1
        \tReceived:
        \t4

        \tat /IceIce/Tests/IceTests/IceTests.swift:9
        
        
        """)
    }
    
    func testXCTLessThanOrEqual() {
        let test = createTest(TestSuite(mode: .all))
        test.send("""
        Test Suite 'AddTests' started at 2017-09-18 10:18:14.163
        Test Case '-[CLITests.AddTests testBasicAdd]' started.
        """)
        test.send("/IceIce/Tests/IceTests/IceTests.swift:9: error: -[IceTests.IceTests testExample] : XCTAssertLessThanOrEqual failed: (\"4\") is greater than (\"1\") - ")
        test.send("""
        Test Case '-[CLITests.AddTests testBasicAdd]' failed (0.716 seconds).
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect("""
         RUNS  CLITests.AddTests
         FAIL  CLITests.AddTests
        
         ● testBasicAdd

        \tExpected value less than or equal to:
        \t1
        \tReceived:
        \t4

        \tat /IceIce/Tests/IceTests/IceTests.swift:9
        
        
        """)
    }
    
    func testMultilineEquality() {
        let test = createTest(TestSuite(mode: .all))
        test.send("""
        Test Suite 'AddTests' started at 2017-09-18 10:18:14.163
        Test Case '-[CLITests.AddTests testBasicAdd]' started.
        /IceIce/Tests/IceTests/IceTests.swift:9: error: -[IceTests.IceTests testExample] : XCTAssertEqual failed: ("first line
        second line") is not equal to ("first line
        """)
        test.send("third line\") - ")
        test.send("""
        Test Case '-[CLITests.AddTests testBasicAdd]' failed (0.716 seconds).
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect("""
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

        \tat /IceIce/Tests/IceTests/IceTests.swift:9
        
        
        """)
    }
    
    func testAllTests() {
        let test = createTest(TestErr())
        test.send("""
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
        test.send("/IceIce/Tests/IceTests/IceTests.swift:11: error: -[IceTests.SomeTests testTwo] : failed - ")
        test.send("/IceIce/Tests/IceTests/IceTests.swift:12: error: -[IceTests.SomeTests testTwo] : failed - ")
        test.send("""
        Test Case '-[IceTests.SomeTests testTwo]' failed (0.001 seconds).
        Test Suite 'SomeTests' failed at 2017-09-18 21:46:20.488.
             Executed 2 tests, with 2 failures (0 unexpected) in 0.001 (0.001) seconds
        Test Suite 'IcePackageTests.xctest' failed at 2017-09-18 21:46:20.488.
             Executed 4 tests, with 2 failures (0 unexpected) in 0.082 (0.082) seconds
        Test Suite 'All tests' failed at 2017-09-18 21:46:20.488.
             Executed 4 tests, with 2 failures (0 unexpected) in 0.082 (0.082) seconds
        """)
        test.expect("""

        IcePackageTests:

         RUNS  IceTests.OtherTests
         PASS  IceTests.OtherTests
         RUNS  IceTests.SomeTests
         FAIL  IceTests.SomeTests

         ● testTwo

        \tXCTFail

        \tat /IceIce/Tests/IceTests/IceTests.swift:11


        \tXCTFail

        \tat /IceIce/Tests/IceTests/IceTests.swift:12
        
        
        Tests:\t1 failed, 3 passed, 4 total
        Time:\t0.082s
        
        
        """)
    }
    
    func testSelectedTests() {
        let test = createTest(TestErr())
        test.send("""
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
        test.send("/IceIce/Tests/IceTests/IceTests.swift:11: error: -[IceTests.SomeTests testTwo] : failed - ")
        test.send("/IceIce/Tests/IceTests/IceTests.swift:12: error: -[IceTests.SomeTests testTwo] : failed - ")
        test.send("""
        Test Case '-[IceTests.SomeTests testTwo]' failed (0.077 seconds).
        Test Suite 'SomeTests' failed at 2017-09-18 21:53:48.936.
             Executed 1 test, with 2 failures (0 unexpected) in 0.077 (0.077) seconds
        Test Suite 'IcePackageTests.xctest' failed at 2017-09-18 21:53:48.936.
             Executed 1 test, with 2 failures (0 unexpected) in 0.077 (0.077) seconds
        Test Suite 'Selected tests' failed at 2017-09-18 21:53:48.936.
             Executed 1 test, with 2 failures (0 unexpected) in 0.077 (0.077) seconds
        """)
        test.expect("""

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

        \tat /IceIce/Tests/IceTests/IceTests.swift:11


        \tXCTFail

        \tat /IceIce/Tests/IceTests/IceTests.swift:12


        Tests:\t1 failed, 1 total
        Time:\t0.077s
        
        
        """)
    }
    
    func testInterleavedOutput() {
        let test = createTest(TestErr())
        test.send("""
        Test Suite 'Selected tests' started at 2017-09-23 08:49:17.352
        Test Suite 'IcePackageTests.xctest' started at 2017-09-23 08:49:17.353
        Test Suite 'RegistryTests' started at 2017-09-23 08:49:17.353
        Test Case '-[CoreTests.RegistryTests testRefresh]' started.
        Cloning into 'Registry/shared'...
        Test Case '-[CoreTests.RegistryTests testRefresh]' passed (0.936 seconds).
        Test Suite 'RegistryTests' passed at 2017-09-23 08:49:18.289.
             Executed 1 test, with 0 failures (0 unexpected) in 0.936 (0.936) seconds
        Test Suite 'IcePackageTests.xctest' passed at 2017-09-23 08:49:18.289.
             Executed 1 test, with 0 failures (0 unexpected) in 0.936 (0.936) seconds
        Test Suite 'Selected tests' passed at 2017-09-23 08:49:18.289.
             Executed 1 test, with 0 failures (0 unexpected) in 0.936 (0.936) seconds
        """)
        test.expect("""
        
        IcePackageTests:

         RUNS  CoreTests.RegistryTests/testRefresh
         PASS  CoreTests.RegistryTests/testRefresh

        Tests:\t1 passed, 1 total
        Time:\t0.936s
        
        
        """)
    }
    
    func testNoTests() {
        let test = createTest(TestErr())
        test.send("error: no tests found; create a target in the 'Tests' directory")
        test.expect("""
        
        Error: no tests found; create a target in the 'Tests' directory
        
        
        """)
    }
    
    func testNoFilterMatch() {
        let test = createTest(TestErr())
        test.send("note: '--filter' predicate did not match any test case")
        test.expect("""
        
        Error: filter predicate did not match any test case
        
        
        """)
    }
    
    private func createTest(_ transformer: Transformer) -> TransformerTest {
        return TransformerTest(transformer: transformer, isStdout: false)
    }
    
}
