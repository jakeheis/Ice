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
        XCTAssertEqual(result.stdout, """
        +----------+-----------------+----------+--------+
        | Name     | Wanted          | Resolved | Latest |
        +----------+-----------------+----------+--------+
        | SwiftCLI | 4.0.3 ..< 5.0.0 | 4.1.2    | 5.1.0  |
        +----------+-----------------+----------+--------+
        
        """)
    }
    
    func testOutdatedNoDependencies() {
        let result = Runner.execute(args: ["outdated"], sandbox: .lib)
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
    }

}
