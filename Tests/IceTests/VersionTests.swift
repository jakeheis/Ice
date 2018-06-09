//
//  VersionTests.swift
//  CLITests
//
//  Created by Jake Heiser on 6/5/18.
//

import XCTest

class VersionTests: XCTestCase {

    static var allTests = [
        ("testVersion", testVersion),
    ]
    
    func testVersion() {
        let buildResult = Runner.execute(args: ["--version"], sandbox: .exec)
        XCTAssertEqual(buildResult.exitStatus, 0)
        XCTAssertEqual(buildResult.stderr, "")
        
        buildResult.stdout.assert { (v) in
            v.matches("Ice version: \\d\\.\\d\\.\\d")
            v.matches("Swift version: \\d\\.\\d(\\.\\d)?")
        }
    }

}
