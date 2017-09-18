//
//  ResolveTests.swift
//  TransformersTests
//
//  Created by Jake Heiser on 9/17/17.
//

import XCTest
import Transformers

class ResolveTests: XCTestCase {
    
    func testFetch() {
        let fetch = TransformTest(Transformers.resolve)
        fetch.send(.out, """
        Fetching https://github.com/jakeheis/SwiftCLI
        
        """)
        fetch.expect(stdout: """
        Fetch https://github.com/jakeheis/SwiftCLI

        """, stderr: "")
    }
    
}
