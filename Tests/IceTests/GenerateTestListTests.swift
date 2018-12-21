//
//  GenerateTestListTests.swift
//  IceTests
//
//  Created by Jake Heiser on 11/25/18.
//

import TestingUtilities
import XCTest

class GenerateTestListTests: XCTestCase {

    func testGenerate() {
        let icebox = IceBox(template: .lib)
        
        let result = icebox.run("generate-test-list")
        
        Differentiate.byPlatform(mac: {
            Differentiate.byVersion(swift4_1AndAbove: {
                XCTAssertEqual(result.exitStatus, 0)
                XCTAssertEqual(result.stderr, "")
                XCTAssertEqual(result.stdout, """
                Compile Lib (1 sources)
                Compile LibTests (1 sources)
                Link ./.build/x86_64-apple-macosx10.10/debug/LibPackageTests.xctest/Contents/MacOS/LibPackageTests
                
                """)
                
                XCTAssertEqual(icebox.fileContents("Tests/LinuxMain.swift"), """
                import XCTest
                
                import LibTests
                
                var tests = [XCTestCaseEntry]()
                tests += LibTests.__allTests()
                
                XCTMain(tests)

                """)
                
                XCTAssertEqual(icebox.fileContents("Tests/LibTests/XCTestManifests.swift"), """
                import XCTest

                extension LibTests {
                    static let __allTests = [
                        ("testExample", testExample),
                    ]
                }

                #if !os(macOS)
                public func __allTests() -> [XCTestCaseEntry] {
                    return [
                        testCase(LibTests.__allTests),
                    ]
                }
                #endif
                
                """)
            }, swift4_0AndAbove: {
                XCTAssertEqual(result.exitStatus, 1)
                XCTAssertEqual(result.stdout, "")
                XCTAssertEqual(result.stderr, """
                
                Error: test list generation only supported for Swift 4.1 and above
                
                
                """)
            })
        }, linux: {
            XCTAssertEqual(result.exitStatus, 1)
            XCTAssertEqual(result.stdout, "")
            XCTAssertEqual(result.stderr, """

            Error: test list generation is not supported on Linux


            """)
        })
    }

}
