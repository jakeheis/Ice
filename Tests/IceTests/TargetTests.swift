//
//  TargetTests.swift
//  CLITests
//
//  Created by Jake Heiser on 9/14/17.
//

import TestingUtilities
import XCTest

class TargetTests: XCTestCase {
    
    static var allTests = [
        ("testBasicAdd", testBasicAdd),
        ("testDependAdd", testDependAdd),
        ("testTargetRemove", testTargetRemove),
        ("testSystemAdd", testSystemAdd),
    ]
    
    func testBasicAdd() {
        let icebox = IceBox(template: .lib)
        
        let result = icebox.run("target", "add", "Core")
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stdout, "")
        XCTAssertEqual(result.stderr, "")
        
        XCTAssertEqual(icebox.fileContents("Package.swift"), """
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
        let icebox = IceBox(template: .lib)
        
        let result = icebox.run("target", "add", "Core", "-d", "Lib")
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stdout, "")
        XCTAssertEqual(result.stderr, "")
        
        XCTAssertEqual(icebox.fileContents("Package.swift"), """
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
    
    func testTargetRemove() {
        let icebox = IceBox(template: .lib)
        
        let result = icebox.run("target", "remove", "Lib")
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stdout, "")
        XCTAssertEqual(result.stderr, "")
        
        XCTAssertEqual(icebox.fileContents("Package.swift"), """
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
    
    func testSystemAdd() {
        let icebox = IceBox(template: .lib)
        
        icebox.execute(with: "tools-version", "update", "4.2")
        
        let result = icebox.run("target", "add", "CSSH", "-s")
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stdout, "")
        XCTAssertEqual(result.stderr, "")
        
        XCTAssertEqual(icebox.fileContents("Package.swift"), """
        // swift-tools-version:4.2
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
                .systemLibrary(name: \"CSSH\"),
            ]
        )

        """)
    }
    
}
