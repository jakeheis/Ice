//
//  TargetTests.swift
//  CLITests
//
//  Created by Jake Heiser on 9/14/17.
//

import XCTest

class TargetTests: XCTestCase {
    
    func testBasicAdd() {
        let result = Runner.execute(args: ["target", "add", "Core"], sandbox: .lib)
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
            targets: [
                .target(name: "Lib", dependencies: []),
                .testTarget(name: "LibTests", dependencies: ["Lib"]),
                .target(name: "Core", dependencies: []),
            ]
        )

        """)
    }
    
    func testDependAdd() {
        let result = Runner.execute(args: ["target", "add", "Core", "-d", "Lib"], sandbox: .lib)
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
            targets: [
                .target(name: "Lib", dependencies: []),
                .testTarget(name: "LibTests", dependencies: ["Lib"]),
                .target(name: "Core", dependencies: ["Lib"]),
            ]
        )

        """)
    }
    
    func testTargetAddAndDepend() {
        let addResult = Runner.execute(args: ["target", "add", "IntegrationTests", "-t"], sandbox: .lib)
        XCTAssertEqual(addResult.exitStatus, 0)
        XCTAssertEqual(addResult.stdout, "")
        XCTAssertEqual(addResult.stderr, "")
        
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
            targets: [
                .target(name: "Lib", dependencies: []),
                .testTarget(name: "LibTests", dependencies: ["Lib"]),
                .testTarget(name: "IntegrationTests", dependencies: []),
            ]
        )

        """)
        
        let dependResult = Runner.execute(args: ["target", "depend", "IntegrationTests", "Lib"], clean: false)
        XCTAssertEqual(dependResult.exitStatus, 0)
        XCTAssertEqual(dependResult.stdout, "")
        XCTAssertEqual(dependResult.stderr, "")
        
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
            targets: [
                .target(name: "Lib", dependencies: []),
                .testTarget(name: "LibTests", dependencies: ["Lib"]),
                .testTarget(name: "IntegrationTests", dependencies: ["Lib"]),
            ]
        )

        """)
    }
    
    func testTargetRemove() {
        let result = Runner.execute(args: ["target", "remove", "Lib"], sandbox: .lib)
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
                .library(name: "Lib", targets: []),
            ],
            targets: [
                .testTarget(name: "LibTests", dependencies: []),
            ]
        )

        """)
    }
    
}
