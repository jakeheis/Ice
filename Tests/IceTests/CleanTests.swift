//
//  CleanTests.swift
//  CLITests
//
//  Created by Jake Heiser on 9/14/17.
//

import TestingUtilities
import XCTest

class CleanTests: XCTestCase {
    
    func testClean() {
        let icebox = IceBox(template: .lib)
        
        icebox.run("build")
        XCTAssertTrue(icebox.fileExists(".build/debug"))
        
        let binResult = icebox.run("clean")
        XCTAssertEqual(binResult.exitStatus, 0)
        XCTAssertEqual(binResult.stderr, "")
        XCTAssertEqual(binResult.stdout, "")
        
        XCTAssertFalse(icebox.fileExists(".build/debug"))
    }
    
}
