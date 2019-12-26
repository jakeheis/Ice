//
//  VersionTests.swift
//  CLITests
//
//  Created by Jake Heiser on 6/5/18.
//

import TestingUtilities
import XCTest

class VersionTests: XCTestCase {
    
    func testVersion() {
        let result = IceBox(template: .lib).run("--version")
        IceAssertEqual(result.exitStatus, 0)
        IceAssertEqual(result.stderr, "")
        
        result.assertStdout { (v) in
            v.matches("Ice version: \\d\\.\\d\\.\\d")
            v.matches("Swift version: \\d\\.\\d(\\.\\d)?")
        }
    }

}
