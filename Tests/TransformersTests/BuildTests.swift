//
//  BuildTests.swift
//  TransformersTests
//
//  Created by Jake Heiser on 9/16/17.
//

import XCTest
import Exec
import Transformers

class BuildTests: XCTestCase {
    
    func testCompile() {
        let build = TransformTest(Transformers.build)
        build.send(.out, """
        Compile Swift Module 'Sup' (1 sources)
        
        """)
        build.expect(stdout: """
        Compile Sup (1 sources)

        """, stderr: "")
    }
    
}
