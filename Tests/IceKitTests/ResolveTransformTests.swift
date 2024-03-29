//
//  ResolveTransformTests.swift
//  IceKitTests
//
//  Created by Jake Heiser on 9/17/17.
//

@testable import IceKit
import XCTest

class ResolveTransformTests: XCTestCase {
    
    func testFetch() {
        let fetch = createTest()
        fetch.send("""
        Fetching https://github.com/jakeheis/SwiftCLI
        Fetching https://github.com/jakeheis/SwiftCLI from cache
        Garbage that should be
        ignored
        
        """)
        fetch.expect("""
        Fetch https://github.com/jakeheis/SwiftCLI
        Fetch https://github.com/jakeheis/SwiftCLI

        """)
    }
    
    func testUpdate() {
        let update = createTest()
        update.send("""
        Updating https://github.com/sharplet/Regex
        """)
        update.expect("""
        Update https://github.com/sharplet/Regex

        """)
    }
    
    func testResolve() {
        let resolve = createTest()
        resolve.send("""
        Resolving https://github.com/sharplet/Regex at 1.1.0
        """)
        resolve.expect("""
        Resolve https://github.com/sharplet/Regex at 1.1.0

        """)
    }
    
    private func createTest() -> TransformerTest {
        return TransformerTest(transformer: ResolveOut(), isStdout: true)
    }
    
}
