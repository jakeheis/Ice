//
//  PackageTests.swift
//  IceKitTests
//
//  Created by Jake Heiser on 9/11/17.
//

import XCTest
import Foundation
import PathKit
import SwiftCLI
@testable import IceKit

class PackageTests: XCTestCase {
    
    static var allTests = [
        ("testBasic", testBasic),
        ("testComplex", testComplex),
    ]
    
    func testBasic() throws {
        XCTAssertEqual(try loadAndWritePackage(path: "SwiftCLI.json"), """
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
        XCTAssertEqual(try loadAndWritePackage(path: "Ice.json"), """
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

        """)
    }
    
    func loadAndWritePackage(path: String) throws -> String {
        let data = try Data(contentsOf: URL(fileURLWithPath: "Tests/Fixtures/\(path)"))
        let package = try PackageLoader.load(from: data)
        let captureStream = CaptureStream()
        try package.write(to: captureStream)
        captureStream.closeWrite()
        
        return captureStream.readAll()
    }
    
}
