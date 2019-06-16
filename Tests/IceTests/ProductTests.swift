//
//  ProductTests.swift
//  CLITests
//
//  Created by Jake Heiser on 9/24/17.
//

import TestingUtilities
import XCTest

class ProductTests: XCTestCase {
    
    func testAddExec() {
        let icebox = IceBox(template: .lib)
        
        let result = icebox.run("product", "add", "gogo", "--exec")
        IceAssertEqual(result.exitStatus, 0)
        IceAssertEqual(result.stdout, "")
        IceAssertEqual(result.stderr, "")
        
        IceAssertEqual(icebox.fileContents("Package.swift"), """
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
        IceAssertEqual(result.exitStatus, 0)
        IceAssertEqual(result.stdout, "")
        IceAssertEqual(result.stderr, "")
        
        IceAssertEqual(icebox.fileContents("Package.swift"), """
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
        IceAssertEqual(result.exitStatus, 0)
        IceAssertEqual(result.stdout, "")
        IceAssertEqual(result.stderr, "")
        
        IceAssertEqual(icebox.fileContents("Package.swift"), """
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
