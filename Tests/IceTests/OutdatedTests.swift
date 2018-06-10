//
//  OutdatedTests.swift
//  CLITests
//
//  Created by Jake Heiser on 3/9/18.
//

import XCTest

class OutdatedTests: XCTestCase {
    
    static var allTests = [
        ("testOutdated", testOutdated),
    ]
    
    func testOutdated() {
        let result = Runner.execute(args: ["outdated"], sandbox: .exec)
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        result.stdout.assert { (v) in
            v.equals("+----------+-----------------+----------+--------+")
            v.equals("| Name     | Wanted          | Resolved | Latest |")
            v.equals("+----------+-----------------+----------+--------+")
            v.matches("\\| SwiftCLI \\| 4\\.0\\.3 \\.\\.< 5\\.0\\.0 \\| 4\\.1\\.2    \\| \\d\\.\\d\\.\\d  \\|")
            v.equals("+----------+-----------------+----------+--------+")
            v.empty()
            v.done()
        }
    }
    
    func testOutdatedNoDependencies() {
        let result = Runner.execute(args: ["outdated"], sandbox: .lib)
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
    }

}
