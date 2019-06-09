//
//  ToolsVersionTests.swift
//  IceTests
//
//  Created by Jake Heiser on 8/13/18.
//

import Icebox
import TestingUtilities
import XCTest

class ToolsVersionTests: XCTestCase {

    func testGet() {
        let icebox = IceBox(template: .lib)
        
        let result = icebox.run("tools-version", "get")
        IceAssertEqual(result.exitStatus, 0)
        IceAssertEqual(result.stderr, "")
        IceAssertEqual(result.stdout, "Swift tools version: 4.0\n")
    }
    
    func testUpdate() {
        let icebox = IceBox(template: .lib)
        
        icebox.createFile(path: "Package.swift", contents: """
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
            ],
            swiftLanguageVersions: [4, 5]
        )
        """)
        
        let result = icebox.run("tools-version", "update", "4.2")
        IceAssertEqual(result.exitStatus, 0)
        IceAssertEqual(result.stderr, "")
        IceAssertEqual(result.stdout, "")
        
        IceAssertEqual(icebox.fileContents("Package.swift"), """
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
            ],
            swiftLanguageVersions: [.v4, .version("5")]
        )
        
        """)
    }

    func testTaggedUpdate() {
        let icebox = IceBox(template: .lib)
        
        icebox.createFile(path: "Package.swift", contents: """
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
            ],
            swiftLanguageVersions: [4, 5]
        )
        
        """)
        
        let result = icebox.run("tools-version", "update", "4.2", "-t")
        IceAssertEqual(result.exitStatus, 0)
        IceAssertEqual(result.stderr, "")
        IceAssertEqual(result.stdout, "")
        
        IceAssertEqual(icebox.fileContents("Package.swift"), """
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
            ],
            swiftLanguageVersions: [4, 5]
        )
        
        """)
        
        IceAssertEqual(icebox.fileContents("Package@swift-4.2.swift"), """
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
            ],
            swiftLanguageVersions: [.v4, .version("5")]
        )
        
        """)
    }
    
}
