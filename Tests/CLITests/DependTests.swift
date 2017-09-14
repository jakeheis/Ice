//
//  DependTests.swift
//  CLITests
//
//  Created by Jake Heiser on 9/14/17.
//

import XCTest

class DependTests: XCTestCase {
    
    
    func testDepend() {
        let result = Runner.execute(args: ["depend", "Exec", "-o", "Just"], sandbox: .exec)
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        XCTAssertEqual(result.stdout, "")
        
        XCTAssertEqual(sandboxedFileContents("Package.swift"), """
        // swift-tools-version:4.0
        // Managed by ice

        import PackageDescription

        let package = Package(
            name: "Exec",
            dependencies: [
                .package(url: "https://github.com/jakeheis/SwiftCLI", from: "3.0.3"),
            ],
            targets: [
                .target(name: "Exec", dependencies: ["SwiftCLI", "Just"]),
            ]
        )

        """)
    }
    
}
