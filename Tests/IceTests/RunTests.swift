//
//  RunTests.swift
//  CLITests
//
//  Created by Jake Heiser on 9/14/17.
//

import TestingUtilities
import XCTest

class RunTests: XCTestCase {
    
    func testBasicRun() {
        let icebox = IceBox(template: .exec)
        
        icebox.run("build")

        let result = icebox.run("run")
        IceAssertEqual(result.exitStatus, 0)
        IceAssertEqual(result.stderr, "")
        IceAssertEqual(result.stdout, """
        Hello, world!
        
        """)
    }
    
}
