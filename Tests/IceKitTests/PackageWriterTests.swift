//
//  PackageWriterTests.swift
//  IceKitTests
//
//  Created by Jake Heiser on 9/24/17.
//

import XCTest
import SwiftCLI
@testable import IceKit

class PackageWriterTests: XCTestCase {
    
    static var allTests = [
        ("testFull", testFull),
        ("testProducts", testProducts),
        ("testDependencies", testDependencies),
        ("testTargets", testTargets),
        ("testProviders", testProviders),
        ("testSwiftLanguageVersions", testSwiftLanguageVersions),
        ("testCLanguageStandard", testCLanguageStandard),
        ("testCxxLanguageStandard", testCxxLanguageStandard),
    ]
    
    func testFull() throws {
        let capture = CaptureStream()
        let writer = try PackageWriter(package: Fixtures.package, toolsVersion: .v4)
        try writer.write(to: capture)
        capture.closeWrite()
        
        XCTAssertEqual(capture.readAll(), """
        // swift-tools-version:4.0
        // Managed by ice

        import PackageDescription

        let package = Package(
            name: "myPackage",
            pkgConfig: "config",
            providers: [
                .brew(["libssh2"]),
                .apt(["libssh2-1-dev", "libssh2-2-dev"]),
            ],
            products: [
                .executable(name: "exec", targets: ["MyLib"]),
                .library(name: "Lib", targets: ["Core"]),
                .library(name: "Static", type: .static, targets: ["MyLib"]),
                .library(name: "Dynamic", type: .dynamic, targets: ["Core"]),
            ],
            dependencies: [
                .package(url: "https://github.com/jakeheis/SwiftCLI", .branch("swift4")),
                .package(url: "https://github.com/jakeheis/Spawn", .exact("0.0.4")),
                .package(url: "https://github.com/jakeheis/Flock", .revision("c57454ce053821d2fef8ad25d8918ae83506810c")),
                .package(url: "https://github.com/jakeheis/FlockCLI", from: "4.1.0"),
                .package(url: "https://github.com/jakeheis/FileKit", .upToNextMinor(from: "2.1.3")),
                .package(url: "https://github.com/jakeheis/Shout", "0.6.4"..<"0.6.8"),
            ],
            targets: [
                .target(name: "CLI", dependencies: ["Core", "FileKit"]),
                .testTarget(name: "CLITests", dependencies: ["CLI", "Core"]),
                .target(name: "Core", dependencies: [], path: "Sources/Diff", exclude: ["ignore.swift"]),
                .target(name: "Exclusive", dependencies: ["Core", "Flock"], sources: ["only.swift"], publicHeadersPath: "headers.h"),
            ],
            swiftLanguageVersions: [3, 4],
            cLanguageStandard: .c90,
            cxxLanguageStandard: .cxx03
        )

        """)
        
        let capture42 = CaptureStream()
        let writer42 = try PackageWriter(package: Fixtures.package, toolsVersion: .v4_2)
        try writer42.write(to: capture42)
        capture42.closeWrite()
        
        XCTAssertEqual(capture42.readAll(), """
        // swift-tools-version:4.2
        // Managed by ice

        import PackageDescription

        let package = Package(
            name: "myPackage",
            pkgConfig: "config",
            providers: [
                .brew(["libssh2"]),
                .apt(["libssh2-1-dev", "libssh2-2-dev"]),
            ],
            products: [
                .executable(name: "exec", targets: ["MyLib"]),
                .library(name: "Lib", targets: ["Core"]),
                .library(name: "Static", type: .static, targets: ["MyLib"]),
                .library(name: "Dynamic", type: .dynamic, targets: ["Core"]),
            ],
            dependencies: [
                .package(url: "https://github.com/jakeheis/SwiftCLI", .branch("swift4")),
                .package(url: "https://github.com/jakeheis/Spawn", .exact("0.0.4")),
                .package(url: "https://github.com/jakeheis/Flock", .revision("c57454ce053821d2fef8ad25d8918ae83506810c")),
                .package(url: "https://github.com/jakeheis/FlockCLI", from: "4.1.0"),
                .package(url: "https://github.com/jakeheis/FileKit", .upToNextMinor(from: "2.1.3")),
                .package(url: "https://github.com/jakeheis/Shout", "0.6.4"..<"0.6.8"),
            ],
            targets: [
                .target(name: "CLI", dependencies: ["Core", "FileKit"]),
                .testTarget(name: "CLITests", dependencies: ["CLI", "Core"]),
                .target(name: "Core", dependencies: [], path: "Sources/Diff", exclude: ["ignore.swift"]),
                .target(name: "Exclusive", dependencies: ["Core", "Flock"], sources: ["only.swift"], publicHeadersPath: "headers.h"),
            ],
            swiftLanguageVersions: [.v3, .v4],
            cLanguageStandard: .c90,
            cxxLanguageStandard: .cxx03
        )

        """)
    }
    
    func testProducts() {
        let result = with4_0 { $0.addProducts(Fixtures.products, to: $1) }
        XCTAssertEqual(result, """
            products: [
                .executable(name: "exec", targets: ["MyLib"]),
                .library(name: "Lib", targets: ["Core"]),
                .library(name: "Static", type: .static, targets: ["MyLib"]),
                .library(name: "Dynamic", type: .dynamic, targets: ["Core"]),
            ]

        """)
    }
    
    func testDependencies() {
        let result = with4_0 { $0.addDependencies(Fixtures.dependencies, to: $1) }
        XCTAssertEqual(result, """
            dependencies: [
                .package(url: "https://github.com/jakeheis/SwiftCLI", .branch("swift4")),
                .package(url: "https://github.com/jakeheis/Spawn", .exact("0.0.4")),
                .package(url: "https://github.com/jakeheis/Flock", .revision("c57454ce053821d2fef8ad25d8918ae83506810c")),
                .package(url: "https://github.com/jakeheis/FlockCLI", from: "4.1.0"),
                .package(url: "https://github.com/jakeheis/FileKit", .upToNextMinor(from: "2.1.3")),
                .package(url: "https://github.com/jakeheis/Shout", "0.6.4"..<"0.6.8"),
            ]

        """)
    }
    
    func testTargets() {
        let result = with4_0 { $0.addTargets(Fixtures.targets, to: $1) }
        XCTAssertEqual(result, """
            targets: [
                .target(name: "CLI", dependencies: ["Core", "FileKit"]),
                .testTarget(name: "CLITests", dependencies: ["CLI", "Core"]),
                .target(name: "Core", dependencies: [], path: "Sources/Diff", exclude: ["ignore.swift"]),
                .target(name: "Exclusive", dependencies: ["Core", "Flock"], sources: ["only.swift"], publicHeadersPath: "headers.h"),
            ]

        """)
    }
    
    func testProviders() {
        let result = with4_0 { $0.addProviders(Fixtures.providers, to: $1) }
        XCTAssertEqual(result, """
            providers: [
                .brew(["libssh2"]),
                .apt(["libssh2-1-dev", "libssh2-2-dev"]),
            ]

        """)
    }
    
    func testSwiftLanguageVersions() throws {
        let result40 = try with4_0 {
            try $0.addSwiftLanguageVersions(Fixtures.package.swiftLanguageVersions, to: $1)
        }
        XCTAssertEqual(result40, """
            swiftLanguageVersions: [3, 4]

        """)
        
        let result42 = with4_2 { $0.addSwiftLanguageVersions(Fixtures.package.swiftLanguageVersions, to: $1) }
        XCTAssertEqual(result42, """
            swiftLanguageVersions: [.v3, .v4]

        """)
        
        XCTAssertThrowsError(try with4_0 { try $0.addSwiftLanguageVersions(["4.2"], to: $1) })
    }
    
    func testCLanguageStandard() {
        let result = with4_0 {
            $0.addCLangaugeStandard("c90", to: $1)
            $0.addCLangaugeStandard("iso9899:199409", to: $1)
        }
        XCTAssertEqual(result, """
            cLanguageStandard: .c90,
            cLanguageStandard: .iso9899_199409

        """)
    }
    
    func testCxxLanguageStandard() {
        let result = with4_0 {
            $0.addCxxLangaugeStandard("c++03", to: $1)
            $0.addCxxLangaugeStandard("gnu++1z", to: $1)
        }
        XCTAssertEqual(result, """
            cxxLanguageStandard: .cxx03,
            cxxLanguageStandard: .gnucxx1z

        """)
    }
    
    // MARK: -
    
    private func withWriter<T: PackageWriterImpl>(_ toolsVersion: SwiftToolsVersion, _ run: (T, PackageArguments) throws -> ()) rethrows -> String {
        let arguments = PackageArguments()
        let writer = T(package: Fixtures.package, toolsVersion: toolsVersion)
        try run(writer, arguments)
        
        let capture = CaptureStream()
        arguments.write(to: capture)
        capture.closeWrite()
        
        return capture.readAll()
    }
    
    private func with4_0(_ run: (Version4_0Writer, PackageArguments) throws -> ()) rethrows -> String {
        return try withWriter(.v4, run)
    }
    
    private func with4_2(_ run: (Version4_2Writer, PackageArguments) throws -> ()) rethrows -> String {
        return try withWriter(.v4_2, run)
    }
    
}
