//
//  CleanTests.swift
//  CLITests
//
//  Created by Jake Heiser on 9/14/17.
//

import XCTest

class CleanTests: XCTestCase {
    
    func testClean() {
        Runner.execute(args: ["build"], sandbox: .lib)
        
        XCTAssertTrue(sandboxFileExists(path: ".build/debug"))
        
        let binResult = Runner.execute(args: ["clean"], clean: false)
        XCTAssertEqual(binResult.exitStatus, 0)
        XCTAssertEqual(binResult.stderr, "")
        XCTAssertEqual(binResult.stdout, "")
        
        XCTAssertFalse(sandboxFileExists(path: ".build/debug"))
    }
    
}
