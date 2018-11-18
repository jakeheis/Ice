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
            cLanguageStandard: .iso9899_199409,
            cxxLanguageStandard: .gnucxx1z
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
            cLanguageStandard: .iso9899_199409,
            cxxLanguageStandard: .gnucxx1z
        )

        """)
    }
    
    func testProducts() {
        let result = with4_0 { $0.addProducts(to: &$1) }
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
        let result = with4_0 { $0.addDependencies(to: &$1) }
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
        
        let result2 = with4_2 { $0.addDependencies(to: &$1) }
        XCTAssertEqual(result2, """
            dependencies: [
                .package(url: "https://github.com/jakeheis/SwiftCLI", .branch("swift4")),
                .package(url: "https://github.com/jakeheis/Spawn", .exact("0.0.4")),
                .package(url: "https://github.com/jakeheis/Flock", .revision("c57454ce053821d2fef8ad25d8918ae83506810c")),
                .package(url: "https://github.com/jakeheis/FlockCLI", from: "4.1.0"),
                .package(url: "https://github.com/jakeheis/FileKit", .upToNextMinor(from: "2.1.3")),
                .package(url: "https://github.com/jakeheis/Shout", "0.6.4"..<"0.6.8"),
                .package(path: "/Projects/PathKit"),
            ]
        """)
    }
    
    func testTargets() throws {
        let result = with4_0 { $0.addTargets(to: &$1) }
        XCTAssertEqual(result, """
            targets: [
                .target(name: "CLI", dependencies: ["Core", "FileKit"]),
                .testTarget(name: "CLITests", dependencies: ["CLI", "Core"]),
                .target(name: "Core", dependencies: [], path: "Sources/Diff", exclude: ["ignore.swift"]),
                .target(name: "Exclusive", dependencies: ["Core", "Flock"], sources: ["only.swift"], publicHeadersPath: "headers.h"),
            ]
        """)
        
        let result2 = with4_2 { $0.addTargets(to: &$1) }
        XCTAssertEqual(result2, """
            targets: [
                .target(name: "CLI", dependencies: ["Core", "FileKit"]),
                .testTarget(name: "CLITests", dependencies: ["CLI", "Core"]),
                .target(name: "Core", dependencies: [], path: "Sources/Diff", exclude: ["ignore.swift"]),
                .target(name: "Exclusive", dependencies: ["Core", "Flock"], sources: ["only.swift"], publicHeadersPath: "headers.h"),
                .systemLibrary(name: "Clibssh2", path: "aPath", pkgConfig: "pc", providers: [
                    .brew(["libssh2"]),
                    .apt(["libssh2-1-dev", "libssh2-2-dev"]),
                ]),
            ]
        """)
    }
    
    func testProviders() {
        let result = with4_0 { $0.addProviders(to: &$1) }
        XCTAssertEqual(result, """
            providers: [
                .brew(["libssh2"]),
                .apt(["libssh2-1-dev", "libssh2-2-dev"]),
            ]
        """)
    }
    
    func testSwiftLanguageVersions() throws {
        let result40 = with4_0 { $0.addSwiftLanguageVersions(to: &$1) }
        XCTAssertEqual(result40, """
            swiftLanguageVersions: [3, 4]
        """)
        
        let result42 = with4_2 { $0.addSwiftLanguageVersions(to: &$1) }
        XCTAssertEqual(result42, """
            swiftLanguageVersions: [.v3, .v4, .v4_2]
        """)
    }
    
    func testCLanguageStandard() {
        let result = with4_0 { $0.addCLangaugeStandard(to: &$1) }
        XCTAssertEqual(result, """
            cLanguageStandard: .iso9899_199409
        """)
    }
    
    func testCxxLanguageStandard() {
        let result = with4_0 { $0.addCxxLangaugeStandard(to: &$1) }
        XCTAssertEqual(result, """
            cxxLanguageStandard: .gnucxx1z
        """)
    }
    
    func testCanWrite() {
        var localDep = Fixtures.package
        localDep.dependencies = Fixtures.package4_2.dependencies
        XCTAssertFalse(Version4_0Writer(package: localDep, toolsVersion: .v4).canWrite())
        XCTAssertTrue(Version4_2Writer(package: localDep, toolsVersion: .v4_2).canWrite())
        
        var systemTarget = Fixtures.package
        systemTarget.targets = Fixtures.package4_2.targets
        XCTAssertFalse(Version4_0Writer(package: systemTarget, toolsVersion: .v4).canWrite())
        XCTAssertTrue(Version4_2Writer(package: systemTarget, toolsVersion: .v4_2).canWrite())
        
        var swiftLangVersions = Fixtures.package
        swiftLangVersions.swiftLanguageVersions = Fixtures.package4_2.swiftLanguageVersions
        XCTAssertFalse(Version4_0Writer(package: swiftLangVersions, toolsVersion: .v4).canWrite())
        XCTAssertTrue(Version4_2Writer(package: swiftLangVersions, toolsVersion: .v4_2).canWrite())
    }
    
    // MARK: -
    
    private func withWriter<T: PackageWriterImpl>(_ toolsVersion: SwiftToolsVersion, _ package: ModernPackageData, _ run: (T, inout FunctionCallComponent) throws -> ()) rethrows -> String {
        var function = FunctionCallComponent(name: "Package")
        let writer = T(package: package, toolsVersion: toolsVersion)
        try run(writer, &function)
        
        var renderedLines = function.render().components(separatedBy: "\n")
        renderedLines.removeFirst()
        renderedLines.removeLast()
        return renderedLines.joined(separator: "\n")
    }
    
    private func with4_0(_ run: (Version4_0Writer, inout FunctionCallComponent) throws -> ()) rethrows -> String {
        return try withWriter(.v4, Fixtures.package, run)
    }
    
    private func with4_2(_ run: (Version4_2Writer, inout FunctionCallComponent) throws -> ()) rethrows -> String {
        return try withWriter(.v4_2, Fixtures.package4_2, run)
    }
    
}
