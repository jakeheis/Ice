//
//  OutdatedTests.swift
//  CLITests
//
//  Created by Jake Heiser on 3/9/18.
//

import TestingUtilities
import XCTest

class OutdatedTests: XCTestCase {
    
    func testOutdated() {
        let result = IceBox(template: .exec).run("outdated")
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        result.assertStdout { (t) in
            t.equals("+----------+-----------------+----------+--------+")
            t.equals("| Name     | Wanted          | Resolved | Latest |")
            t.equals("+----------+-----------------+----------+--------+")
            t.matches("\\| SwiftCLI \\| 4\\.0\\.3 \\.\\.< 5\\.0\\.0 \\| 4\\.1\\.2    \\| \\d\\.\\d\\.\\d  \\|")
            t.equals("+----------+-----------------+----------+--------+")
            t.empty()
            t.done()
        }
    }
    
    func testOutdatedNoDependencies() {
        let result = IceBox(template: .lib).run("outdated")
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
    }

}
