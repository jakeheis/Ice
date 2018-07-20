//
//  TestTests.swift
//  CLITests
//
//  Created by Jake Heiser on 9/14/17.
//

import Icebox
import XCTest

class TestTests: XCTestCase {
    
    static var allTests = [
        ("testStructure", testStructure),
    ]
    
    func testStructure() {
        let icebox = IceBox(template: .lib)
        
        let result = icebox.run("test")
        XCTAssertEqual(result.exitStatus, 0)
        
        #if !os(Linux) && !os(Android)
        result.assertStdout { (v) in
            v.equals("Compile Lib (1 sources)")
            v.equals("Compile LibTests (1 sources)")
            v.matches("^Link \\./\\.build/.*/LibPackageTests$")
            v.empty()
            v.done()
        }
        #else
        result.assertStdout { (v) in
            v.equals("Compile Lib (1 sources)")
            v.equals("Compile LibTests (1 sources)")
            v.equals("Compile LibPackageTests (1 sources)")
            v.matches("^Link \\./\\.build/.*/LibPackageTests.xctest$")
            v.empty()
            v.done()
        }
        #endif
        
        result.assertStderr { (v) in
            v.empty()
            v.equals("LibPackageTests:")
            v.empty()
            v.equals(" RUNS  LibTests.LibTests")
            v.equals(" PASS  LibTests.LibTests")
            v.empty()
            v.equals("Tests:\t1 passed, 1 total")
            v.matches("^Time:\t[0-9\\.]+s$")
            v.empty()
            v.empty()
            v.done()
        }
    }
    
}
