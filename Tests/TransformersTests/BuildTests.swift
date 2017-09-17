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
    
    func testCompileC() {
        let build = TransformTest(Transformers.build)
        build.send(.out, """
        Compile RxCocoaRuntime _RXDelegateProxy.m
        Compile RxCocoaRuntime _RXKVOObserver.m
        Compile RxCocoaRuntime _RXObjCRuntime.m
        
        """)
        build.expect(stdout: """
        Compile RxCocoaRuntime

        """, stderr: "")
    }
    
    func testLink() {
        let build = TransformTest(Transformers.build)
        build.send(.out, """
        Linking ./.build/x86_64-apple-macosx10.10/debug/ice
        
        """)
        build.expect(stdout: """
        Link ./.build/x86_64-apple-macosx10.10/debug/ice

        """, stderr: "")
    }
    
}
