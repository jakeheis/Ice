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
            IceAssertEqual(result.exitStatus, 0)
            IceAssertEqual(result.stderr, "")
            IceAssertEqual(result.stdout, """
            Compile Lib/Lib.swift
            Merge Lib
            Compile LibTests/LibTests.swift
            Merge LibTests
            Link LibPackageTests
            
            """)
        }, linux: {
            IceAssertEqual(result.exitStatus, 1)
            IceAssertEqual(result.stdout, "")
            IceAssertEqual(result.stderr, """

            Error: test list generation is not supported on Linux


            """)
        })
    }
    
}
