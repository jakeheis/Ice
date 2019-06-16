//
//  RemoveTests.swift
//  CLITests
//
//  Created by Jake Heiser on 9/13/17.
//

import TestingUtilities
import XCTest

class RemoveTests: XCTestCase {
    
    func testBasicRemove() {
        let icebox = IceBox(template: .exec)
        
        let result = icebox.run("remove", "SwiftCLI")
        IceAssertEqual(result.exitStatus, 0)
        IceAssertEqual(result.stdout, "")
        IceAssertEqual(result.stderr, "")
        
        IceAssertEqual(icebox.fileContents("Package.swift"), """
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
            dependencies: [
                .package(url: "https://github.com/yonaskolb/Mint", from: "0.10.1"),
            ],
            targets: [
                .target(name: "Lib", dependencies: ["MintKit"]),
                .testTarget(name: "LibTests", dependencies: ["Lib"]),
            ]
        )
        """)
        
        let result = icebox.run("remove", "Mint")
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
            ],
            targets: [
                .target(name: "Lib", dependencies: []),
                .testTarget(name: "LibTests", dependencies: ["Lib"]),
            ]
        )

        """)
    }
    
}
