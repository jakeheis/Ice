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
        \(genTestCaseStarted(package: "CLITests", suite: "AddTests", test: "testBasicAdd"))
        \(genTestCasePassed(package: "CLITests", suite: "AddTests", test: "testBasicAdd"))
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        
        test.expect("""
         RUNS  \(getSuite(package: "CLITests", suite: "AddTests"))
         PASS  \(getSuite(package: "CLITests", suite: "AddTests"))
        
        """)
    }
    
    func testXCTFail() {
        let test = createTest(TestSuite(mode: .all))
        test.send("""
        Test Suite 'AddTests' started at 2017-09-18 10:18:14.163
        \(genTestCaseStarted(package: "CLITests", suite: "AddTests", test: "testBasicAdd"))
        """)
        test.send("/IceIce/Tests/IceTests/IceTests.swift:9: error: \(genTestCase(package: "CLITests", suite: "AddTests", test: "testBasicAdd")) : failed - ")
        test.send("""
        \(genTestCaseFailed(package: "CLITests", suite: "AddTests", test: "testBasicAdd"))
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect("""
         RUNS  \(getSuite(package: "CLITests", suite: "AddTests"))
         FAIL  \(getSuite(package: "CLITests", suite: "AddTests"))
        
         ● testBasicAdd

        \tXCTFail

        \tat /IceIce/Tests/IceTests/IceTests.swift:9
        
        
        """)
    }
    
    func testXCTEquals() {
        let test = createTest(TestSuite(mode: .all))
        test.send("""
        Test Suite 'AddTests' started at 2017-09-18 10:18:14.163
        \(genTestCaseStarted(package: "CLITests", suite: "AddTests", test: "testBasicAdd"))
        """)
        test.send("/IceIce/Tests/IceTests/IceTests.swift:9: error: \(genTestCase(package: "CLITests", suite: "AddTests", test: "testBasicAdd")) : XCTAssertEqual failed: (\"Hello, World!\") is not equal to (\"Hello, Worldddd!\") - ")
        test.send("""
        \(genTestCaseStarted(package: "CLITests", suite: "AddTests", test: "testBasicAdd"))
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect("""
         RUNS  \(getSuite(package: "CLITests", suite: "AddTests"))
         FAIL  \(getSuite(package: "CLITests", suite: "AddTests"))
        
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
        \(genTestCaseStarted(package: "CLITests", suite: "AddTests", test: "testBasicAdd"))
        """)
        test.send("/IceIce/Tests/IceTests/IceTests.swift:23: error: \(genTestCase(package: "CLITests", suite: "AddTests", test: "testBasicAdd")) : XCTAssertEqualWithAccuracy failed: (\"4.0\") is not equal to (\"5.0\") +/- (\"0.5\") - ")
        test.send("""
        \(genTestCaseFailed(package: "CLITests", suite: "AddTests", test: "testBasicAdd"))
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect("""
         RUNS  \(getSuite(package: "CLITests", suite: "AddTests"))
         FAIL  \(getSuite(package: "CLITests", suite: "AddTests"))
        
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
        \(genTestCaseStarted(package: "CLITests", suite: "AddTests", test: "testBasicAdd"))
        """)
        test.send("/IceIce/Tests/IceTests/IceTests.swift:9: error: \(genTestCase(package: "CLITests", suite: "AddTests", test: "testBasicAdd")) : XCTAssertNotEqual failed: (\"hello world\") is equal to (\"hello world\") - ")
        test.send("""
        \(genTestCaseFailed(package: "CLITests", suite: "AddTests", test: "testBasicAdd"))
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect("""
         RUNS  \(getSuite(package: "CLITests", suite: "AddTests"))
         FAIL  \(getSuite(package: "CLITests", suite: "AddTests"))
        
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
        \(genTestCaseStarted(package: "CLITests", suite: "AddTests", test: "testBasicAdd"))
        """)
        test.send("/IceIce/Tests/IceTests/IceTests.swift:23: error: \(genTestCase(package: "CLITests", suite: "AddTests", test: "testBasicAdd")) : XCTAssertNotEqualWithAccuracy failed: (\"4.0\") is equal to (\"4.5\") +/- (\"0.5\") - ")
        test.send("""
        \(genTestCaseFailed(package: "CLITests", suite: "AddTests", test: "testBasicAdd"))
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect("""
         RUNS  \(getSuite(package: "CLITests", suite: "AddTests"))
         FAIL  \(getSuite(package: "CLITests", suite: "AddTests"))
        
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
        \(genTestCaseStarted(package: "CLITests", suite: "AddTests", test: "testBasicAdd"))
        """)
        test.send("/IceIce/Tests/IceTests/IceTests.swift:9: error: \(genTestCase(package: "CLITests", suite: "AddTests", test: "testBasicAdd")) : XCTAssertNil failed: \"hello world\" - The value should be nil")
        test.send("""
        \(genTestCaseFailed(package: "CLITests", suite: "AddTests", test: "testBasicAdd"))
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect("""
         RUNS  \(getSuite(package: "CLITests", suite: "AddTests"))
         FAIL  \(getSuite(package: "CLITests", suite: "AddTests"))
        
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
        \(genTestCaseStarted(package: "CLITests", suite: "AddTests", test: "testBasicAdd"))
        """)
        test.send("/IceIce/Tests/IceTests/IceTests.swift:9: error: \(genTestCase(package: "CLITests", suite: "AddTests", test: "testBasicAdd")) : XCTAssertNotNil failed - The value should not be nil")
        test.send("""
        \(genTestCaseFailed(package: "CLITests", suite: "AddTests", test: "testBasicAdd"))
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect("""
         RUNS  \(getSuite(package: "CLITests", suite: "AddTests"))
         FAIL  \(getSuite(package: "CLITests", suite: "AddTests"))
        
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
        \(genTestCaseStarted(package: "CLITests", suite: "AddTests", test: "testBasicAdd"))
        """)
        test.send("/IceIce/Tests/IceTests/IceTests.swift:9: error: \(genTestCase(package: "CLITests", suite: "AddTests", test: "testBasicAdd")) : XCTAssertThrowsError failed: did not throw an error - ")
        test.send("""
        \(genTestCaseFailed(package: "CLITests", suite: "AddTests", test: "testBasicAdd"))
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect("""
         RUNS  \(getSuite(package: "CLITests", suite: "AddTests"))
         FAIL  \(getSuite(package: "CLITests", suite: "AddTests"))
        
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
        \(genTestCaseStarted(package: "CLITests", suite: "AddTests", test: "testBasicAdd"))
        """)
        test.send("/IceIce/Tests/IceTests/IceTests.swift:9: error: \(genTestCase(package: "CLITests", suite: "AddTests", test: "testBasicAdd")) : XCTAssertNoThrow failed: threw error \"Error Domain=ice Code=1 \"(null)\"\" - ")
        test.send("""
        \(genTestCaseFailed(package: "CLITests", suite: "AddTests", test: "testBasicAdd"))
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect("""
         RUNS  \(getSuite(package: "CLITests", suite: "AddTests"))
         FAIL  \(getSuite(package: "CLITests", suite: "AddTests"))
        
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
        \(genTestCaseStarted(package: "CLITests", suite: "AddTests", test: "testBasicAdd"))
        """)
        test.send("/IceIce/Tests/IceTests/IceTests.swift:9: error: \(genTestCase(package: "CLITests", suite: "AddTests", test: "testBasicAdd")) : XCTAssert failed - ")
        test.send("""
        \(genTestCaseFailed(package: "CLITests", suite: "AddTests", test: "testBasicAdd"))
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect("""
         RUNS  \(getSuite(package: "CLITests", suite: "AddTests"))
         FAIL  \(getSuite(package: "CLITests", suite: "AddTests"))
        
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
        \(genTestCaseStarted(package: "CLITests", suite: "AddTests", test: "testBasicAdd"))
        """)
        test.send("/IceIce/Tests/IceTests/IceTests.swift:9: error: \(genTestCase(package: "CLITests", suite: "AddTests", test: "testBasicAdd")) : XCTAssertTrue failed - ")
        test.send("""
        \(genTestCaseFailed(package: "CLITests", suite: "AddTests", test: "testBasicAdd"))
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect("""
         RUNS  \(getSuite(package: "CLITests", suite: "AddTests"))
         FAIL  \(getSuite(package: "CLITests", suite: "AddTests"))
        
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
        \(genTestCaseStarted(package: "CLITests", suite: "AddTests", test: "testBasicAdd"))
        """)
        test.send("/IceIce/Tests/IceTests/IceTests.swift:9: error: \(genTestCase(package: "CLITests", suite: "AddTests", test: "testBasicAdd")) : XCTAssertFalse failed - ")
        test.send("""
        \(genTestCaseFailed(package: "CLITests", suite: "AddTests", test: "testBasicAdd"))
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect("""
         RUNS  \(getSuite(package: "CLITests", suite: "AddTests"))
         FAIL  \(getSuite(package: "CLITests", suite: "AddTests"))
        
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
        \(genTestCaseStarted(package: "CLITests", suite: "AddTests", test: "testBasicAdd"))
        """)
        test.send("/IceIce/Tests/IceTests/IceTests.swift:9: error: \(genTestCase(package: "CLITests", suite: "AddTests", test: "testBasicAdd")) : XCTAssertGreaterThan failed: (\"1\") is not greater than (\"4\") - one should be greater than four")
        test.send("""
        \(genTestCaseFailed(package: "CLITests", suite: "AddTests", test: "testBasicAdd"))
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect("""
         RUNS  \(getSuite(package: "CLITests", suite: "AddTests"))
         FAIL  \(getSuite(package: "CLITests", suite: "AddTests"))
        
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
        \(genTestCaseStarted(package: "CLITests", suite: "AddTests", test: "testBasicAdd"))
        """)
        test.send("/IceIce/Tests/IceTests/IceTests.swift:9: error: \(genTestCase(package: "CLITests", suite: "AddTests", test: "testBasicAdd")) : XCTAssertGreaterThanOrEqual failed: (\"1\") is less than (\"4\") - one should be greater than or equal to four")
        test.send("""
        \(genTestCaseFailed(package: "CLITests", suite: "AddTests", test: "testBasicAdd"))
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect("""
         RUNS  \(getSuite(package: "CLITests", suite: "AddTests"))
         FAIL  \(getSuite(package: "CLITests", suite: "AddTests"))
        
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
        \(genTestCaseStarted(package: "CLITests", suite: "AddTests", test: "testBasicAdd"))
        """)
        test.send("/IceIce/Tests/IceTests/IceTests.swift:9: error: \(genTestCase(package: "CLITests", suite: "AddTests", test: "testBasicAdd")) : XCTAssertLessThan failed: (\"4\") is not less than (\"1\") - ")
        test.send("""
        \(genTestCaseFailed(package: "CLITests", suite: "AddTests", test: "testBasicAdd"))
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect("""
         RUNS  \(getSuite(package: "CLITests", suite: "AddTests"))
         FAIL  \(getSuite(package: "CLITests", suite: "AddTests"))
        
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
        \(genTestCaseStarted(package: "CLITests", suite: "AddTests", test: "testBasicAdd"))
        """)
        test.send("/IceIce/Tests/IceTests/IceTests.swift:9: error: \(genTestCase(package: "CLITests", suite: "AddTests", test: "testBasicAdd")) : XCTAssertLessThanOrEqual failed: (\"4\") is greater than (\"1\") - ")
        test.send("""
        \(genTestCaseFailed(package: "CLITests", suite: "AddTests", test: "testBasicAdd"))
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect("""
         RUNS  \(getSuite(package: "CLITests", suite: "AddTests"))
         FAIL  \(getSuite(package: "CLITests", suite: "AddTests"))
        
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
        \(genTestCaseStarted(package: "CLITests", suite: "AddTests", test: "testBasicAdd"))
        /IceIce/Tests/IceTests/IceTests.swift:9: error: \(genTestCase(package: "CLITests", suite: "AddTests", test: "testBasicAdd")) : XCTAssertEqual failed: ("first line
        second line") is not equal to ("first line
        """)
        test.send("third line\") - ")
        test.send("""
        \(genTestCaseFailed(package: "CLITests", suite: "AddTests", test: "testBasicAdd"))
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        test.expect("""
         RUNS  \(getSuite(package: "CLITests", suite: "AddTests"))
         FAIL  \(getSuite(package: "CLITests", suite: "AddTests"))
        
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
        let test = createTest(TestMain())
        #if os(macOS)
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
        #else
        test.send("""
        Test Suite 'All tests' started at 2017-09-18 21:46:20.406
        Test Suite 'debug.xctest' started at 2018-08-05 22:49:08.274
        Test Suite 'OtherTests' started at 2017-09-18 21:46:20.406
        Test Case 'OtherTests.testOne' started at 2018-08-05 15:56:37.983
        Test Case 'OtherTests.testOne' passed (0.080 seconds).
        Test Case 'OtherTests.testTwo' started at 2018-08-05 15:56:37.983
        Test Case 'OtherTests.testTwo' passed (0.000 seconds).
        Test Suite 'OtherTests' passed at 2017-09-18 21:46:20.487.
             Executed 2 tests, with 0 failures (0 unexpected) in 0.080 (0.080) seconds
        Test Suite 'SomeTests' started at 2017-09-18 21:46:20.487
        Test Case 'SomeTests.testOne' started at 2018-08-05 15:56:37.983
        Test Case 'SomeTests.testOne' passed (0.000 seconds).
        Test Case 'SomeTests.testTwo' started at 2018-08-05 15:56:37.983
        """)
        test.send("/IceIce/Tests/IceTests/IceTests.swift:11: error: SomeTests.testTwo : failed - ")
        test.send("/IceIce/Tests/IceTests/IceTests.swift:12: error: SomeTests.testTwo : failed - ")
        test.send("""
        Test Case 'SomeTests.testTwo' failed (0.001 seconds).
        Test Suite 'SomeTests' failed at 2017-09-18 21:46:20.488.
             Executed 2 tests, with 2 failures (0 unexpected) in 0.001 (0.001) seconds
        Test Suite 'debug.xctest' passed at 2018-08-05 22:49:08.280
            Executed 1 test, with 0 failures (0 unexpected) in 0.001 (0.001) seconds
        Test Suite 'All tests' failed at 2017-09-18 21:46:20.488.
             Executed 4 tests, with 2 failures (0 unexpected) in 0.082 (0.082) seconds
        """)
        test.expect("""

         RUNS  OtherTests
         PASS  OtherTests
         RUNS  SomeTests
         FAIL  SomeTests

         ● testTwo

        \tXCTFail

        \tat /IceIce/Tests/IceTests/IceTests.swift:11


        \tXCTFail

        \tat /IceIce/Tests/IceTests/IceTests.swift:12
        
        
        Tests:\t1 failed, 3 passed, 4 total
        Time:\t0.082s
        
        
        """)
        #endif
    }
    
    func testSelectedTests() {
        let test = createTest(TestMain())
        #if os(macOS)
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
        test.send("/IceIce/Tests/IceTests/IceTests.swift:11: error: -[IceTests.SomeTests testTwo] : failed - ") // Needs space at end; in mulitline quote, gets trimmed
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
        #else
        test.send("""
        Test Suite 'Selected tests' started at 2017-09-18 21:53:48.479
        Test Suite 'OtherTests' started at 2017-09-18 21:53:48.480
        Test Case 'OtherTests.testOne' started at 2018-08-05 16:13:48.631
        Test Case 'OtherTests.testOne' passed (0.079 seconds)
        Test Suite 'OtherTests' passed at 2017-09-18 21:53:48.558
             Executed 1 test, with 0 failures (0 unexpected) in 0.079 (0.079) seconds
        Test Suite 'Selected tests' passed at 2017-09-18 21:53:48.559
             Executed 1 test, with 0 failures (0 unexpected) in 0.079 (0.080) seconds
        Test Suite 'Selected tests' started at 2017-09-18 21:53:48.607
        Test Suite 'OtherTests' started at 2017-09-18 21:53:48.607
        Test Case 'OtherTests.testTwo' started at 2018-08-05 15:56:37.983
        Test Case 'OtherTests.testTwo' passed (0.072 seconds).
        Test Suite 'OtherTests' passed at 2017-09-18 21:53:48.679.
             Executed 1 test, with 0 failures (0 unexpected) in 0.072 (0.072) seconds
        Test Suite 'Selected tests' passed at 2017-09-18 21:53:48.679.
             Executed 1 test, with 0 failures (0 unexpected) in 0.072 (0.073) seconds
        Test Suite 'Selected tests' started at 2017-09-18 21:53:48.729
        Test Suite 'SomeTests' started at 2017-09-18 21:53:48.729
        Test Case 'SomeTests.testOne' started at 2018-08-05 15:56:37.983
        Test Case 'SomeTests.testOne' passed (0.082 seconds).
        Test Suite 'SomeTests' passed at 2017-09-18 21:53:48.811.
             Executed 1 test, with 0 failures (0 unexpected) in 0.082 (0.082) seconds
        Test Suite 'Selected tests' passed at 2017-09-18 21:53:48.811.
             Executed 1 test, with 0 failures (0 unexpected) in 0.082 (0.082) seconds
        Test Suite 'Selected tests' started at 2017-09-18 21:53:48.859
        Test Suite 'SomeTests' started at 2017-09-18 21:53:48.859
        Test Case 'SomeTests.testTwo' started at 2018-08-05 15:56:37.983
        """)
        test.send("/IceIce/Tests/IceTests/IceTests.swift:11: error: SomeTests.testTwo : failed - ") // Needs space at end; in mulitline quote, gets trimmed
        test.send("/IceIce/Tests/IceTests/IceTests.swift:12: error: SomeTests.testTwo : failed - ")
        test.send("""
        Test Case 'SomeTests.testTwo' failed (0.077 seconds).
        Test Suite 'SomeTests' failed at 2017-09-18 21:53:48.936.
             Executed 1 test, with 2 failures (0 unexpected) in 0.077 (0.077) seconds
        Test Suite 'Selected tests' failed at 2017-09-18 21:53:48.936.
             Executed 1 test, with 2 failures (0 unexpected) in 0.077 (0.077) seconds
        """)
        test.expect("""

         RUNS  OtherTests/testOne
         PASS  OtherTests/testOne

        Tests:\t1 passed, 1 total
        Time:\t0.080s

         RUNS  OtherTests/testTwo
         PASS  OtherTests/testTwo

        Tests:\t1 passed, 1 total
        Time:\t0.073s

         RUNS  SomeTests/testOne
         PASS  SomeTests/testOne

        Tests:\t1 passed, 1 total
        Time:\t0.082s

         RUNS  SomeTests/testTwo
         FAIL  SomeTests/testTwo

         ● testTwo

        \tXCTFail

        \tat /IceIce/Tests/IceTests/IceTests.swift:11


        \tXCTFail

        \tat /IceIce/Tests/IceTests/IceTests.swift:12


        Tests:\t1 failed, 1 total
        Time:\t0.077s
        
        
        """)
        #endif
    }
    
    func testInterleavedOutput() {
        let test = createTest(TestMain())
        #if os(macOS)
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
        #else
        test.send("""
        Test Suite 'Selected tests' started at 2017-09-23 08:49:17.352
        Test Suite 'RegistryTests' started at 2017-09-23 08:49:17.353
        Test Case 'RegistryTests.testRefresh' started.
        Cloning into 'Registry/shared'...
        Test Case 'RegistryTests.testRefresh' passed (0.936 seconds).
        Test Suite 'RegistryTests' passed at 2017-09-23 08:49:18.289.
             Executed 1 test, with 0 failures (0 unexpected) in 0.936 (0.936) seconds
        Test Suite 'Selected tests' passed at 2017-09-23 08:49:18.289.
             Executed 1 test, with 0 failures (0 unexpected) in 0.936 (0.936) seconds
        """)
        test.expect("""
        
         RUNS  RegistryTests/testRefresh
         PASS  RegistryTests/testRefresh

        Tests:\t1 passed, 1 total
        Time:\t0.936s
        
        
        """)
        #endif
    }
    
    func testNoTests() {
        let test = createTest(TestMain())
        test.send("error: no tests found; create a target in the 'Tests' directory")
        test.expect("""
        
        Error: no tests found; create a target in the 'Tests' directory
        
        
        """)
    }
    
    func testNoFilterMatch() {
        let test = createTest(TestMain())
        test.send("note: '--filter' predicate did not match any test case")
        test.expect("""
        
        Error: filter predicate did not match any test case
        
        
        """)
    }
    
    private func createTest(_ transformer: Transformer) -> TransformerTest {
        return TransformerTest(transformer: transformer, isStdout: false)
    }
    
    private func genTestCase(package: String, suite: String, test: String) -> String {
        #if os(macOS)
        return "-[\(package).\(suite) \(test)]"
        #else
        return "\(suite).\(test)"
        #endif
    }
    
    private func genTestCaseStarted(package: String, suite: String, test: String) -> String {
        #if os(macOS)
        return "Test Case '\(genTestCase(package: package, suite: suite, test: test))' started."
        #else
        return "Test Case '\(genTestCase(package: package, suite: suite, test: test))' started at 2018-08-05 15:56:37.983"
        #endif
    }
    
    
    private func genTestCasePassed(package: String, suite: String, test: String) -> String {
        return "Test Case '\(genTestCase(package: package, suite: suite, test: test))' failed (0.716 seconds)."
    }
    
    private func genTestCaseFailed(package: String, suite: String, test: String) -> String {
        return "Test Case '\(genTestCase(package: package, suite: suite, test: test))' failed (0.716 seconds)."
    }
    
    private func getSuite(package: String, suite: String) -> String {
        #if os(macOS)
        return "\(package).\(suite)"
        #else
        return suite
        #endif
    }
    
}
