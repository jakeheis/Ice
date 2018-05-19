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
            testCase(ConfigTests.allTests),
            testCase(PackageTests.allTests),
            testCase(PacakgeWriterTests.allTests),
            testCase(RegistryTests.allTests),
            testCase(RepositoryReferenceTests.allTests),
            testCase(VersionTests.allTests),
        ]
    }
#endif
