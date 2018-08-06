//
//  ProductTests.swift
//  CLITests
//
//  Created by Jake Heiser on 9/24/17.
//

import TestingUtilities
import XCTest

class ProductTests: XCTestCase {
    
    static var allTests = [
        ("testAddExec", testAddExec),
        ("testAddLib", testAddLib),
        ("testRemove", testRemove),
    ]
    
    func testAddExec() {
        let icebox = IceBox(template: .lib)
        
        let result = icebox.run("product", "add", "gogo", "--exec")
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
                .executable(name: "gogo", targets: []),
            ],
            targets: [
                .target(name: "Lib", dependencies: []),
                .testTarget(name: "LibTests", dependencies: ["Lib"]),
            ]
        )

        """)
    }
    
    func testAddLib() {
        let icebox = IceBox(template: .lib)
        
        let result = icebox.run("product", "add", "Static", "-s", "-t", "Lib")
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
                .library(name: "Static", type: .static, targets: ["Lib"]),
            ],
            targets: [
                .target(name: "Lib", dependencies: []),
                .testTarget(name: "LibTests", dependencies: ["Lib"]),
            ]
        )

        """)
    }
    
    func testRemove() {
        let icebox = IceBox(template: .lib)
        
        let result = icebox.run("product", "remove", "Lib")
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stdout, "")
        XCTAssertEqual(result.stderr, "")
        
        XCTAssertEqual(icebox.fileContents("Package.swift"), """
        // swift-tools-version:4.0
        // Managed by ice

        import PackageDescription

        let package = Package(
            name: "Lib",
            targets: [
                .target(name: "Lib", dependencies: []),
                .testTarget(name: "LibTests", dependencies: ["Lib"]),
            ]
        )

        """)
    }
    
}
