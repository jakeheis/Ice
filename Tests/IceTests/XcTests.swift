//
//  XcTests.swift
//  CLITests
//
//  Created by Jake Heiser on 9/13/17.
//

import XCTest

class XcTests: XCTestCase {
    
    static var allTests = [
        ("testXc", testXc),
    ]
    
    func testXc() {
        let icebox = IceBox(template: .lib)
        
        let result = icebox.run("xc", "-n")
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stdout, """
        Generated Lib.xcodeproj
        
        """)
        XCTAssertEqual(result.stderr, "")
        
        XCTAssertTrue(icebox.fileExists("Lib.xcodeproj"))
    }
    
}
