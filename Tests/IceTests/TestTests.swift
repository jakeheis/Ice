//
//  TestTests.swift
//  CLITests
//
//  Created by Jake Heiser on 9/14/17.
//

import TestingUtilities
import XCTest

class TestTests: XCTestCase {
    
    func testGenerateList() {
        let icebox = IceBox(template: .lib)
        
        let result = icebox.run("test", "--generate-list")
        
        Differentiate.byPlatform(mac: {
            Differentiate.byVersion(swift4_1AndAbove: {
                XCTAssertEqual(result.exitStatus, 0)
                XCTAssertEqual(result.stderr, "")
                XCTAssertEqual(result.stdout, """
                Compile Lib (1 sources)
                Compile LibTests (1 sources)
                Link ./.build/x86_64-apple-macosx10.10/debug/LibPackageTests.xctest/Contents/MacOS/LibPackageTests
                
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
