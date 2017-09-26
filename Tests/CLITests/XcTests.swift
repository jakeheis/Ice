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
        let result = Runner.execute(args: ["xc", "-n"], sandbox: .lib)
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stdout, """
        generated: ./Lib.xcodeproj
        
        """)
        XCTAssertEqual(result.stderr, "")
        
        XCTAssertTrue(sandboxFileExists(path: "Lib.xcodeproj"))
    }
    
}
