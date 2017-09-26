//
//  TestTests.swift
//  CLITests
//
//  Created by Jake Heiser on 9/14/17.
//

import XCTest

class TestTests: XCTestCase {
    
    static var allTests = [
        ("testStructure", testStructure),
    ]
    
    func testStructure() {
        let result = Runner.execute(args: ["test"], sandbox: .lib)
        XCTAssertEqual(result.exitStatus, 0)
        
        result.stdout.assert { (v) in
            v.equals("Compile Lib (1 sources)")
            v.equals("Compile LibTests (1 sources)")
            v.matches("^Link \\./\\.build/.*/LibPackageTests$")
            v.empty()
            v.done()
        }
        result.stderr.assert { (v) in
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
