//
//  UpdateTests.swift
//  CLITests
//
//  Created by Jake Heiser on 9/25/17.
//

import XCTest

class UpdateTests: XCTestCase {
    
    static var allTests = [
        ("testUpdate", testUpdate),
    ]
    
    func testUpdate() {
        let buildResult = Runner.execute(args: ["build"], sandbox: .exec)
        XCTAssertEqual(buildResult.exitStatus, 0)
        XCTAssertEqual(buildResult.stderr, "")
        
        let result = Runner.execute(args: ["update"], clean: false)
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        XCTAssertEqual(result.stdout, """
        Update https://github.com/jakeheis/SwiftCLI
        
        """)
    }
    
}
