//
//  XCTestManifests.swift
//  CoreTests
//
//  Created by Jake Heiser on 9/25/17.
//

import XCTest

#if !os(macOS)
    public func allTests() -> [XCTestCaseEntry] {
        return [
            testCase(BuildTests.allTests),
            testCase(InitTests.allTests),
            testCase(LineTests.allTests),
            testCase(ResolveTests.allTests),
            testCase(TestTests.allTests),
            testCase(UpdateTests.allTests),
        ]
    }
#endif
