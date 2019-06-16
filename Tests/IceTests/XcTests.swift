//
//  XcTests.swift
//  CLITests
//
//  Created by Jake Heiser on 9/13/17.
//

import TestingUtilities
import XCTest

class XcTests: XCTestCase {
    
    func testXc() {
        let icebox = IceBox(template: .lib)
        
        let result = icebox.run("xc", "-n")
        IceAssertEqual(result.exitStatus, 0)
        IceAssertEqual(result.stdout, """
        Generated Lib.xcodeproj
        
        """)
        IceAssertEqual(result.stderr, "")
        
        XCTAssertTrue(icebox.fileExists("Lib.xcodeproj"))
    }
    
}
