//
//  RemoveTests.swift
//  CLITests
//
//  Created by Jake Heiser on 9/13/17.
//

import XCTest

class RemoveTests: XCTestCase {
    
    static var allTests = [
        ("testBasicRemove", testBasicRemove),
        ("testRemoveDifferentName", testRemoveDifferentName),
    ]
    
    func testBasicRemove() {
        let result = Runner.execute(args: ["remove", "SwiftCLI"], sandbox: .exec)
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stdout, "")
        XCTAssertEqual(result.stderr, "")
        
        XCTAssertEqual(sandboxedFileContents("Package.swift"), """
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
    
    func testRemoveDifferentName() {
        let result = Runner.execute(args: ["remove", "Mint"], sandbox: .lib, sandboxSetup: {
            writeToSandbox(path: "Package.swift", contents: """
            // swift-tools-version:4.0
            // Managed by ice

            import PackageDescription

            let package = Package(
                name: "Lib",
                products: [
                    .library(name: "Lib", targets: ["Lib"]),
                ],
                dependencies: [
                    .package(url: "https://github.com/yonaskolb/Mint", from: "0.10.1"),
                ],
                targets: [
                    .target(name: "Lib", dependencies: ["MintKit"]),
                    .testTarget(name: "LibTests", dependencies: ["Lib"]),
                ]
            )
            """)
        })
        
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stdout, "")
        XCTAssertEqual(result.stderr, "")
        
        XCTAssertEqual(sandboxedFileContents("Package.swift"), """
        // swift-tools-version:4.0
        // Managed by ice

        import PackageDescription

        let package = Package(
            name: "Lib",
            products: [
                .library(name: "Lib", targets: ["Lib"]),
            ],
            targets: [
                .target(name: "Lib", dependencies: []),
                .testTarget(name: "LibTests", dependencies: ["Lib"]),
            ]
        )

        """)
    }
    
}
