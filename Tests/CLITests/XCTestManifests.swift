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
            testCase(AddTests.allTests),
            testCase(BuildTests.allTests),
            testCase(CleanTests.allTests),
            testCase(ConfigTests.allTests),
            testCase(DumpTests.allTests),
            testCase(InitTests.allTests),
            testCase(NewTests.allTests),
            testCase(ProductTests.allTests),
            testCase(RegistryTests.allTests),
            testCase(RemoveTests.allTests),
            testCase(RunTests.allTests),
            testCase(SearchTests.allTests),
            testCase(TargetTests.allTests),
            testCase(TestTests.allTests),
            testCase(UpdateTests.allTests),
            testCase(VersionTests.allTests),
            testCase(XcTests.allTests),
        ]
    }
#endif
