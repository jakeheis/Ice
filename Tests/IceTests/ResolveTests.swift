//
//  ResolveTests.swift
//  CLITests
//
//  Created by Jake Heiser on 4/3/18.
//

import TestingUtilities
import XCTest

class ResolveTests: XCTestCase {
    
    func testResolve() {
        let result = IceBox(template: .exec).run("resolve")
        IceAssertEqual(result.exitStatus, 0)
        IceAssertEqual(result.stderr, "")
        IceAssertEqual(result.stdout, """
        Fetch https://github.com/jakeheis/SwiftCLI
        Clone https://github.com/jakeheis/SwiftCLI
        Resolve https://github.com/jakeheis/SwiftCLI at 4.1.2
        
        """)
    }
    
}
