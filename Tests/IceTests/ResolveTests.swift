//
//  ResolveTests.swift
//  CLITests
//
//  Created by Jake Heiser on 4/3/18.
//

import XCTest

class ResolveTests: XCTestCase {

    static var allTests = [
        ("testResolve", testResolve),
    ]
    
    func testResolve() {
        let result = Runner.execute(args: ["resolve"], sandbox: .exec)
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stdout, """
        Fetch https://github.com/jakeheis/SwiftCLI
        Clone https://github.com/jakeheis/SwiftCLI
        Resolve https://github.com/jakeheis/SwiftCLI at 4.1.2
        
        """)
        XCTAssertEqual(result.stderr, "")
    }
    
}
