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
            testCase(BuildTransformTests.allTests),
            testCase(ConfigTests.allTests),
            testCase(InitTransformTests.allTests),
            testCase(LineTests.allTests),
            testCase(PackageLoaderTests.allTests),
            testCase(PackageWriterTests.allTests),
            testCase(RegistryTests.allTests),
            testCase(RepositoryReferenceTests.allTests),
            testCase(ResolveTransformTests.allTests),
            testCase(TestTransformTests.allTests),
            testCase(VersionTests.allTests),
            testCase(XcTransformTests.allTests),
        ]
    }
#endif
