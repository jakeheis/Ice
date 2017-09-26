//
//  UpdateTests.swift
//  TransformersTests
//
//  Created by Jake Heiser on 9/25/17.
//

import XCTest
@testable import Transformers

class UpdateTests: XCTestCase {
    
    static var allTests = [
        ("testUpdate", testUpdate),
        ("testResolve", testResolve),
    ]
    
    func testUpdate() {
        let build = TransformTest(Transformers.update)
        build.send(.out, """
        Updating https://github.com/sharplet/Regex
        """)
        build.expect(stdout: """
        Update https://github.com/sharplet/Regex

        """, stderr: "")
    }
    
    func testResolve() {
        let build = TransformTest(Transformers.update)
        build.send(.out, """
        Resolving https://github.com/sharplet/Regex at 1.1.0
        """)
        build.expect(stdout: """
        Resolve https://github.com/sharplet/Regex at 1.1.0

        """, stderr: "")
    }
    
}
