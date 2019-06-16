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
            Differentiate.byVersion(swift5AndAbove: {
                IceAssertEqual(result.exitStatus, 0)
                IceAssertEqual(result.stderr, "")
                IceAssertEqual(result.stdout, """
                Compile Lib (1 sources)
                Compile LibTests (1 sources)
                Link ./.build/x86_64-apple-macosx/debug/LibPackageTests.xctest/Contents/MacOS/LibPackageTests
                
                """)
            }, swift4_1AndAbove: {
                IceAssertEqual(result.exitStatus, 0)
                IceAssertEqual(result.stderr, "")
                IceAssertEqual(result.stdout, """
                Compile Lib (1 sources)
                Compile LibTests (1 sources)
                Link ./.build/x86_64-apple-macosx10.10/debug/LibPackageTests.xctest/Contents/MacOS/LibPackageTests
                
                """)
            }, swift4_0AndAbove: {
                IceAssertEqual(result.exitStatus, 1)
                IceAssertEqual(result.stdout, "")
                IceAssertEqual(result.stderr, """
                
                Error: test list generation only supported for Swift 4.1 and above
                
                
                """)
            })
        }, linux: {
            IceAssertEqual(result.exitStatus, 1)
            IceAssertEqual(result.stdout, "")
            IceAssertEqual(result.stderr, """

            Error: test list generation is not supported on Linux


            """)
        })
    }
    
}
