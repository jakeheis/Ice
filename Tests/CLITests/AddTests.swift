//
//  AddTests.swift
//  CLITests
//
//  Created by Jake Heiser on 9/13/17.
//

import XCTest

class AddTests: XCTestCase {

    static var allTests = [
        ("testBasicAdd", testBasicAdd),
        ("testTargetAdd", testTargetAdd),
        ("testVersionedAdd", testVersionedAdd),
    ]
    
    func testBasicAdd() {
        let result = Runner.execute(args: ["add", "jakeheis/Spawn", "-n"], sandbox: .lib)
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
            name: "Lib",
            products: [
                .library(name: "Lib", targets: ["Lib"]),
            ],
            dependencies: [
                .package(url: "https://github.com/jakeheis/Spawn", from: "0.0.6"),
            ],
            targets: [
                .target(name: "Lib", dependencies: []),
                .testTarget(name: "LibTests", dependencies: ["Lib"]),
            ]
        )

        """)
    }
    
    func testTargetAdd() {
        let result = Runner.execute(args: ["add", "jakeheis/Spawn", "-t", "Lib"], sandbox: .lib)
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
            name: "Lib",
            products: [
                .library(name: "Lib", targets: ["Lib"]),
            ],
            dependencies: [
                .package(url: "https://github.com/jakeheis/Spawn", from: "0.0.6"),
            ],
            targets: [
                .target(name: "Lib", dependencies: ["Spawn"]),
                .testTarget(name: "LibTests", dependencies: ["Lib"]),
            ]
        )

        """)
    }
    
    func testVersionedAdd() {
        let result = Runner.execute(args: ["add", "jakeheis/Spawn", "0.0.5", "-n"], sandbox: .lib)
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
            name: "Lib",
            products: [
                .library(name: "Lib", targets: ["Lib"]),
            ],
            dependencies: [
                .package(url: "https://github.com/jakeheis/Spawn", from: "0.0.5"),
            ],
            targets: [
                .target(name: "Lib", dependencies: []),
                .testTarget(name: "LibTests", dependencies: ["Lib"]),
            ]
        )

        """)
    }
    
    func testSingleTargetAdd() {
        let result = Runner.execute(args: ["add", "jakeheis/Spawn"], sandbox: .exec)
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
            dependencies: [
                .package(url: "https://github.com/jakeheis/SwiftCLI", from: "4.0.3"),
                .package(url: "https://github.com/jakeheis/Spawn", from: "0.0.6"),
            ],
            targets: [
                .target(name: "Exec", dependencies: ["SwiftCLI", "Spawn"]),
            ]
        )

        """)
    }
    
}
