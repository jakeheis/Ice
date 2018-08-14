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
        ("testAllTests", testAllTests),
        ("testSelectedTests", testSelectedTests),
        ("testInterleavedOutput", testInterleavedOutput),
        ("testNoTests", testNoTests),
        ("testNoFilterMatch", testNoFilterMatch),
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
    ]
    
    // MARK: - General
    
    func testSuitePass() {
        let test = createTest(TestSuite(mode: .all))

        #if os(macOS)
        let testCase = "-[CLITests.AddTests testBasicAdd]"
        test.send("""
        Test Suite 'AddTests' started at 2017-09-18 10:18:14.163
        Test Case '\(testCase)' started.
        Test Case '\(testCase)' passed (0.716 seconds)
        Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """)
        
        test.expect("""
         RUNS  CLITests.AddTests
         PASS  CLITests.AddTests
        
        """)
        #else
        let testCase = "AddTests.testBasicAdd"
        test.send("""
            Test Suite 'AddTests' started at 2017-09-18 10:18:14.163
            Test Case '\(testCase)' started at 2018-08-05 15:56:37.983
            Test Case '\(testCase)' passed (0.716 seconds)
            Test Suite 'AddTests' passed at 2017-09-18 10:18:15.728.
            Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
            """)
        
        test.expect("""
         RUNS  AddTests
         PASS  AddTests
        
        """)
        #endif
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
        /IceIce/Tests/IceTests/IceTests.swift:11: error: -[IceTests.SomeTests testTwo] : failed - \n\
        /IceIce/Tests/IceTests/IceTests.swift:12: error: -[IceTests.SomeTests testTwo] : failed - \n\
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
        /IceIce/Tests/IceTests/IceTests.swift:11: error: SomeTests.testTwo : failed - \n\
        /IceIce/Tests/IceTests/IceTests.swift:12: error: SomeTests.testTwo : failed - \n\
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
        /IceIce/Tests/IceTests/IceTests.swift:11: error: -[IceTests.SomeTests testTwo] : failed - \n\
        /IceIce/Tests/IceTests/IceTests.swift:12: error: -[IceTests.SomeTests testTwo] : failed - \n\
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
        /IceIce/Tests/IceTests/IceTests.swift:11: error: SomeTests.testTwo : failed - \n\
        /IceIce/Tests/IceTests/IceTests.swift:12: error: SomeTests.testTwo : failed - \n\
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
    
    // MARK: - Special cases
    
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
    
    // MARK: - Assertion tests
    
    func testXCTFail() {
        let test = createTest(TestSuite(mode: .all))
        test.send(assertionFailure(assertion: "failed - "))
        test.expect(failedTest(failure: """
        \tXCTFail
        """))
    }
    
    func testXCTEquals() {
        let test = createTest(TestSuite(mode: .all))
        test.send(assertionFailure(assertion: "XCTAssertEqual failed: (\"Hello, World!\") is not equal to (\"Hello, Worldddd!\") - "))
        test.expect(failedTest(failure: """
        \tExpected:
        \tHello, Worldddd!
        \tReceived:
        \tHello, World!
        """))
    }
    
    func testXCTEqualWithAccuracy() {
        let test = createTest(TestSuite(mode: .all))
        test.send(assertionFailure(assertion: "XCTAssertEqualWithAccuracy failed: (\"4.0\") is not equal to (\"5.0\") +/- (\"0.5\") - "))
        test.expect(failedTest(failure: """
        \tExpected:
        \t5.0 (+/- 0.5)
        \tReceived:
        \t4.0
        """))
    }
    
    func testXCTNotEquals() {
        let test = createTest(TestSuite(mode: .all))
        test.send(assertionFailure(assertion: "XCTAssertNotEqual failed: (\"hello world\") is equal to (\"hello world\") - "))
        test.expect(failedTest(failure: """
        \tExpected anything but:
        \thello world
        \tReceived:
        \thello world
        """))
    }
    
    func testXCTNotEqualWithAccuracy() {
        let test = createTest(TestSuite(mode: .all))
        test.send(assertionFailure(assertion: "XCTAssertNotEqualWithAccuracy failed: (\"4.0\") is equal to (\"4.5\") +/- (\"0.5\") - "))
        test.expect(failedTest(failure: """
        \tExpected anything but:
        \t4.5 (+/- 0.5)
        \tReceived:
        \t4.0
        """))
    }
    
    func testXCTNil() {
        let test = createTest(TestSuite(mode: .all))
        test.send(assertionFailure(assertion: "XCTAssertNil failed: \"hello world\" - The value should be nil"))
        test.expect(failedTest(failure: """
        \tExpected:
        \tnil
        \tReceived:
        \thello world

        \tNote: The value should be nil
        """))
    }
    
    func testXCTNotNil() {
        let test = createTest(TestSuite(mode: .all))
        test.send(assertionFailure(assertion: "XCTAssertNotNil failed - The value should not be nil"))
        test.expect(failedTest(failure: """
        \tExpected:
        \tnon-nil
        \tReceived:
        \tnil

        \tNote: The value should not be nil
        """))
    }
    
    func testXCTThrow() {
        let test = createTest(TestSuite(mode: .all))
        test.send(assertionFailure(assertion: "XCTAssertThrowsError failed: did not throw an error - "))
        test.expect(failedTest(failure: """
        \tExpected:
        \terror thrown
        \tReceived:
        \tno error
        """))
    }
    
    func testXCTNoThrow() {
        let test = createTest(TestSuite(mode: .all))
        test.send(assertionFailure(assertion: "XCTAssertNoThrow failed: threw error \"Error Domain=ice Code=1 \"(null)\"\" - "))
        test.expect(failedTest(failure: """
        \tExpected:
        \tno error
        \tReceived:
        \tError Domain=ice Code=1 "(null)"
        """))
    }
    
    func testXCTAssert() {
        let test = createTest(TestSuite(mode: .all))
        test.send(assertionFailure(assertion: "XCTAssert failed - "))
        test.expect(failedTest(failure: """
        \tExpected:
        \ttrue
        \tReceived:
        \tfalse
        """))
    }
    
    func testXCTTrue() {
        let test = createTest(TestSuite(mode: .all))
        test.send(assertionFailure(assertion: "XCTAssertTrue failed - "))
        test.expect(failedTest(failure: """
        \tExpected:
        \ttrue
        \tReceived:
        \tfalse
        """))
    }
    
    func testXCTFalse() {
        let test = createTest(TestSuite(mode: .all))
        test.send(assertionFailure(assertion: "XCTAssertFalse failed - "))
        test.expect(failedTest(failure: """
        \tExpected:
        \tfalse
        \tReceived:
        \ttrue
        """))
    }
    
    func testXCTGreaterThan() {
        let test = createTest(TestSuite(mode: .all))
        test.send(assertionFailure(assertion: "XCTAssertGreaterThan failed: (\"1\") is not greater than (\"4\") - one should be greater than four"))
        test.expect(failedTest(failure: """
        \tExpected value greater than:
        \t4
        \tReceived:
        \t1

        \tNote: one should be greater than four
        """))
    }
    
    func testXCTGreaterThanOrEqual() {
        let test = createTest(TestSuite(mode: .all))
        test.send(assertionFailure(assertion: "XCTAssertGreaterThanOrEqual failed: (\"1\") is less than (\"4\") - one should be greater than or equal to four"))
        test.expect(failedTest(failure: """
        \tExpected value greater than or equal to:
        \t4
        \tReceived:
        \t1

        \tNote: one should be greater than or equal to four
        """))
    }
    
    func testXCTLessThan() {
        let test = createTest(TestSuite(mode: .all))
        test.send(assertionFailure(assertion: "XCTAssertLessThan failed: (\"4\") is not less than (\"1\") - "))
        test.expect(failedTest(failure: """
        \tExpected value less than:
        \t1
        \tReceived:
        \t4
        """))
    }
    
    func testXCTLessThanOrEqual() {
        let test = createTest(TestSuite(mode: .all))
        test.send(assertionFailure(assertion: "XCTAssertLessThanOrEqual failed: (\"4\") is greater than (\"1\") - "))
        test.expect(failedTest(failure: """
        \tExpected value less than or equal to:
        \t1
        \tReceived:
        \t4
        """))
    }
    
    func testMultilineEquality() {
        let test = createTest(TestSuite(mode: .all))
        test.send(assertionFailure(assertion: """
        XCTAssertEqual failed: ("first line
        second line") is not equal to ("first line
        third line\") -
        """ + " "))
        test.expect(failedTest(failure: """
        \tExpected:
        \tfirst line
        \tthird line
        \tReceived:
        \tfirst line
        \tsecond line
        \t(end)
        """))
    }
    
    // MARK: - Helpers
    
    private func createTest(_ transformer: Transformer) -> TransformerTest {
        return TransformerTest(transformer: transformer, isStdout: false)
    }
    
    private func assertionFailure(assertion: String) -> String {
        let package = "IceKitTests"
        let suite = "AddTests"
        let test = "testBasicAdd"
        
        #if os(macOS)
        let testCase = "-[\(package).\(suite) \(test)]"
        return """
        Test Suite '\(suite)' started at 2017-09-18 10:18:14.163
        Test Case '\(testCase)' started.
        /IceIce/Tests/IceTests/IceTests.swift:9: error: \(testCase) : \(assertion)
        Test Case '\(testCase)' failed (0.716 seconds).
        Test Suite '\(suite)' passed at 2017-09-18 10:18:15.728.
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """
        #else
        let testCase = "\(suite).\(test)"
        return """
        Test Suite '\(suite)' started at 2017-09-18 10:18:14.163
        Test Case '\(testCase)' started at 2018-08-05 15:56:37.983
        /IceIce/Tests/IceTests/IceTests.swift:9: error: \(testCase) : \(assertion)
        Test Case '\(testCase)' failed (0.716 seconds)
        Test Suite '\(suite)' passed at 2017-09-18 10:18:15.728
             Executed 3 tests, with 0 failures (0 unexpected) in 1.564 (1.564) seconds
        """
        #endif
    }
    
    private func failedTest(failure: String) -> String {
        let package = "IceKitTests"
        let suite = "AddTests"
        let test = "testBasicAdd"
        
        #if os(macOS)
        return """
         RUNS  \(package).\(suite)
         FAIL  \(package).\(suite)
        
         ● \(test)
        
        \(failure)
        
        \tat /IceIce/Tests/IceTests/IceTests.swift:9
        
        
        """
        #else
        return """
         RUNS  \(suite)
         FAIL  \(suite)
        
         ● \(test)
        
        \(failure)
        
        \tat /IceIce/Tests/IceTests/IceTests.swift:9
        
        
        """
        #endif
    }
    
}
