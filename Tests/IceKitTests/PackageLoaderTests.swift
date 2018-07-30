//
//  PackageLoaderTests.swift
//  IceKitTests
//
//  Created by Jake Heiser on 9/11/17.
//

import XCTest
import Foundation
import PathKit
import SwiftCLI
@testable import IceKit

class PackageLoaderTests: XCTestCase {
    
    static var allTests = [
        ("testBasic", testBasic),
        ("testComplex", testComplex),
    ]
    
    private let fixturesPath = Path("Tests/Fixtures")
    
    func testBasic() throws {
        let data: Data = try (fixturesPath + "SwiftCLI.json").read()
        let package = try PackageLoader.load(from: data, directory: Path.current, toolsVersion: SwiftToolsVersion.v4)
        
        XCTAssertEqual(package.directory, Path.current)
        XCTAssertEqual(package.toolsVersion, .v4)
        XCTAssertEqual(package.dirty, false)
        
        let captureStream = CaptureStream()
        try package.write(to: captureStream)
        captureStream.closeWrite()
        
        XCTAssertEqual(captureStream.readAll(), """
        // swift-tools-version:4.0
        // Managed by ice

        import PackageDescription

        let package = Package(
            name: "SwiftCLI",
            products: [
                .library(name: "SwiftCLI", targets: ["SwiftCLI"]),
            ],
            targets: [
                .target(name: "SwiftCLI", dependencies: []),
                .testTarget(name: "SwiftCLITests", dependencies: ["SwiftCLI"]),
            ]
        )
        
        """)
    }
    
    func testComplex() throws {
        let data: Data = try (fixturesPath + "Ice.json").read()
        let package = try PackageLoader.load(from: data, directory: Path.current, toolsVersion: SwiftToolsVersion(major: 4, minor: 1, patch: 0))
        
        XCTAssertEqual(package.directory, Path.current)
        XCTAssertEqual(package.toolsVersion, SwiftToolsVersion(major: 4, minor: 1, patch: 0))
        XCTAssertEqual(package.dirty, false)
        
        let captureStream = CaptureStream()
        try package.write(to: captureStream)
        captureStream.closeWrite()
        
        XCTAssertEqual(captureStream.readAll(), """
        // swift-tools-version:4.1
        // Managed by ice

        import PackageDescription

        let package = Package(
            name: "Ice",
            products: [
                .executable(name: "ice", targets: ["CLI"]),
            ],
            dependencies: [
                .package(url: "https://github.com/JohnSundell/Files", from: "1.11.0"),
                .package(url: "https://github.com/JustHTTP/Just", from: "0.6.0"),
                .package(url: "https://github.com/onevcat/Rainbow", from: "2.1.0"),
                .package(url: "https://github.com/sharplet/Regex", from: "1.1.0"),
                .package(url: "https://github.com/jakeheis/SwiftCLI", .branchItem("master")),
            ],
            targets: [
                .target(name: "CLI", dependencies: ["Core", "SwiftCLI"]),
                .target(name: "Core", dependencies: ["Exec", "Files", "Just", "Rainbow", "Regex"]),
                .target(name: "Exec", dependencies: ["Regex", "SwiftCLI"]),
                .testTarget(name: "CoreTests", dependencies: ["Core"]),
            ]
        )

        """)
    }
    
}
