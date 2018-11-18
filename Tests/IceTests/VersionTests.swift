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
        let buildResult = IceBox(template: .exec).run("--version")
        XCTAssertEqual(buildResult.exitStatus, 0)
        XCTAssertEqual(buildResult.stderr, "")
        
        buildResult.assertStdout { (v) in
            v.matches("Ice version: \\d\\.\\d\\.\\d")
            v.matches("Swift version: \\d\\.\\d(\\.\\d)?")
        }
    }

}
