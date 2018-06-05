//
//  XcTests.swift
//  CLITests
//
//  Created by Jake Heiser on 6/3/18.
//

import XCTest
@testable import Transformers

class XcTests: XCTestCase {
    
    static var allTests = [
        ("testGenerate", testGenerate),
    ]
    
    func testGenerate() {
        let test = TransformerTest(transformer: Xc(), isStdout: true)
        test.send("""
        Fetching https://github.com/ReactiveCocoa/ReactiveSwift.git
        Cloning https://github.com/ReactiveCocoa/ReactiveSwift.git
        Resolving https://github.com/ReactiveCocoa/ReactiveSwift.git at 3.0.0
        generated: ./Carthage.xcodeproj
        """)
        test.expect("""
        Fetch https://github.com/ReactiveCocoa/ReactiveSwift.git
        Clone https://github.com/ReactiveCocoa/ReactiveSwift.git
        Resolve https://github.com/ReactiveCocoa/ReactiveSwift.git at 3.0.0
        Generated Carthage.xcodeproj
        
        """)
    }

}
