import XCTest
import IceTests
import IceKitTests

var tests = [XCTestCaseEntry]()
tests += IceTests.allTests()
tests += IceKitTests.allTests()
XCTMain(tests)
