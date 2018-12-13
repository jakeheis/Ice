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
        #if os(macOS)
        let icebox = IceBox(template: .lib)
        
        let result = icebox.run("test", "--generate-list")
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        XCTAssertEqual(result.stdout, """
        Compile Lib (1 sources)
        Compile LibTests (1 sources)
        Link ./.build/x86_64-apple-macosx10.10/debug/LibPackageTests.xctest/Contents/MacOS/LibPackageTests
        
        """)
        #endif
    }
    
}
