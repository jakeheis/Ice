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
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        XCTAssertEqual(result.stdout, "Swift tools version: 4.0\n")
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
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        XCTAssertEqual(result.stdout, "")
        
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
            ],
            swiftLanguageVersions: [.v4, .version("5")]
        )
        
        """)
    }

}
