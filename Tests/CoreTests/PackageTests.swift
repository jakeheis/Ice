//
//  PackageTests.swift
//  CoreTests
//
//  Created by Jake Heiser on 9/11/17.
//

import XCTest
import Foundation
import Core
import SwiftCLI

class PackageTests: XCTestCase {
    
    func testBasic() throws {
        let expected = """
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
        
        """
        XCTAssertEqual(try writePackage(path: "SwiftCLI.json"), expected)
    }
    
    func testComplex() throws {
        let expected = """
        // swift-tools-version:4.0
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

        """
        XCTAssertEqual(try writePackage(path: "Ice.json"), expected)
    }
    
    func writePackage(path: String) throws -> String {
        let data = try Data(contentsOf: URL(fileURLWithPath: "Tests/Fixtures/\(path)"))
        let package = try Package.load(data: data)
        let captureStream = CaptureStream()
        try package.write(to: captureStream)
        return captureStream.content
    }
    
}
