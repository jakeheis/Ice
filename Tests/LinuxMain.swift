import XCTest
import CLITests
import CoreTests
import TransformersTests

var tests = [XCTestCaseEntry]()
tests += CLITests.allTests()
tests += CoreTests.allTests()
tests += TransformersTests.allTests()
XCTMain(tests)