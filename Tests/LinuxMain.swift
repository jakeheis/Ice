import XCTest

import IceTests
import IceKitTests

var tests = [XCTestCaseEntry]()
tests += IceTests.__allTests()
tests += IceKitTests.__allTests()

XCTMain(tests)
