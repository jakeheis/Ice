import XCTest

import IceKitTests
import IceTests

var tests = [XCTestCaseEntry]()
tests += IceKitTests.__allTests()
tests += IceTests.__allTests()

XCTMain(tests)
