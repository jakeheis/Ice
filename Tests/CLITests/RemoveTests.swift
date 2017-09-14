//
//  RemoveTests.swift
//  CLITests
//
//  Created by Jake Heiser on 9/13/17.
//

import XCTest

class RemoveTests: XCTestCase {
    
    func testBasicRemove() {
        let result = Runner.execute(args: ["remove", "SwiftCLI"], sandbox: .exec)
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stdout, "")
        XCTAssertEqual(result.stderr, "")
        
        XCTAssertEqual(
            sandboxedFileContents("Package.swift"),
            """
        // swift-tools-version:4.0
        // Managed by ice

        import PackageDescription

        let package = Package(
            name: "Exec",
            targets: [
                .target(name: "Exec", dependencies: []),
            ]
        )

        """)
    }
    
}
