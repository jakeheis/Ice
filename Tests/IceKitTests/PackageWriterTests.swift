//
//  PackageWriterTests.swift
//  IceKitTests
//
//  Created by Jake Heiser on 9/24/17.
//

@testable import IceKit
import SwiftCLI
import XCTest

class PackageWriterTests: XCTestCase {
    
    func testFull4_0() throws {
        let capture = CaptureStream()
        let writer = try PackageWriter(package: Fixtures.package4_0.convertToModern(), toolsVersion: .v4)
        try writer.write(to: capture)
        capture.closeWrite()
        
        IceAssertEqual(capture.readAll(), """
        // swift-tools-version:4.0
        // Managed by ice

        import PackageDescription

        let package = Package(
            name: "myPackage",
            pkgConfig: "config",
            providers: [
                .apt(["first", "second"]),
                .brew(["this", "that"]),
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
                .target(name: "CLI", dependencies: ["Core", .product(name: "FileKit")]),
                .testTarget(name: "CLITests", dependencies: [.target(name: "CLI"), "Core"]),
                .target(name: "Core", dependencies: [], path: "Sources/Diff", exclude: ["ignore.swift"]),
                .target(name: "Exclusive", dependencies: ["Core", .product(name: "FlockKit", package: "Flock")], sources: ["only.swift"], publicHeadersPath: "headers.h"),
            ],
            swiftLanguageVersions: [3, 4],
            cLanguageStandard: .iso9899_199409,
            cxxLanguageStandard: .gnucxx1z
        )

        """)
    }
    
    func testFull4_2() throws {
        let capture = CaptureStream()
        let writer = try PackageWriter(package: Fixtures.package4_2.convertToModern(), toolsVersion: .v4_2)
        try writer.write(to: capture)
        capture.closeWrite()
        
        IceAssertEqual(capture.readAll(), """
        // swift-tools-version:4.2
        // Managed by ice
        
        import PackageDescription

        let package = Package(
            name: "myPackage",
            pkgConfig: "config",
            providers: [
                .apt(["first", "second"]),
                .brew(["this", "that"]),
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
                .package(path: "/Projects/PathKit"),
            ],
            targets: [
                .target(name: "CLI", dependencies: ["Core", .product(name: "FileKit")]),
                .testTarget(name: "CLITests", dependencies: [.target(name: "CLI"), "Core"]),
                .target(name: "Core", dependencies: [], path: "Sources/Diff", exclude: ["ignore.swift"]),
                .target(name: "Exclusive", dependencies: ["Core", .product(name: "FlockKit", package: "Flock")], sources: ["only.swift"], publicHeadersPath: "headers.h"),
                .systemLibrary(name: "Clibssh2", path: "aPath", pkgConfig: "pc", providers: [
                    .apt(["third", "fourth"]),
                    .brew(["over", "there"]),
                ]),
            ],
            swiftLanguageVersions: [.v3, .v4, .v4_2],
            cLanguageStandard: .iso9899_199409,
            cxxLanguageStandard: .gnucxx1z
        )

        """)
    }
    
    func testFull5_0() throws {
        let capture = CaptureStream()
        let writer = try PackageWriter(package: Fixtures.package5_0, toolsVersion: .v5)
        try writer.write(to: capture)
        capture.closeWrite()
        
        IceAssertEqual(capture.readAll(), """
        // swift-tools-version:5.0
        // Managed by ice
        
        import PackageDescription

        let package = Package(
            name: "myPackage",
            platforms: [
                .macOS(.v10_14),
                .iOS(.v12),
            ],
            pkgConfig: "config",
            providers: [
                .apt(["first", "second"]),
                .brew(["this", "that"]),
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
                .package(path: "/Projects/PathKit"),
            ],
            targets: [
                .target(name: "CLI", dependencies: ["Core", .product(name: "FileKit")]),
                .testTarget(name: "CLITests", dependencies: [.target(name: "CLI"), "Core"]),
                .target(name: "Core", dependencies: [], path: "Sources/Diff", exclude: ["ignore.swift"]),
                .target(name: "Exclusive", dependencies: ["Core", .product(name: "FlockKit", package: "Flock")], sources: ["only.swift"], publicHeadersPath: "headers.h"),
                .systemLibrary(name: "Clibssh2", path: "aPath", pkgConfig: "pc", providers: [
                    .apt(["third", "fourth"]),
                    .brew(["over", "there"]),
                ]),
                .target(name: "Settings", dependencies: [], cSettings: [
                    .define("FOO"),
                ], cxxSettings: [
                    .headerSearchPath("path", .when()),
                ], swiftSettings: [
                    .unsafeFlags(["f1", "f2"], .when(platforms: [.macOS])),
                ], linkerSettings: [
                    .linkedLibrary("libz", .when(platforms: [.linux], configuration: .release)),
                ]),
            ],
            swiftLanguageVersions: [.v3, .v4, .v4_2],
            cLanguageStandard: .iso9899_199409,
            cxxLanguageStandard: .gnucxx1z
        )

        """)
    }
    
    func testEmpty() throws {
        let capture = CaptureStream()
        let writer = try PackageWriter(package: Fixtures.emptyPackage, toolsVersion: .v5)
        try writer.write(to: capture)
        capture.closeWrite()
        
        IceAssertEqual(capture.readAll(), """
        // swift-tools-version:5.0
        // Managed by ice

        import PackageDescription

        let package = Package(
            name: "Empty",
            targets: [
                .target(name: "CLI", dependencies: []),
                .testTarget(name: "CLITests", dependencies: ["CLI"]),
            ]
        )
        
        """)
    }
    
    func testPlatorms() {
        IceAssertEqual(write5_0 { $0.addPlatforms(to: &$1) }, """
            platforms: [
                .macOS(.v10_14),
                .iOS(.v12),
            ]
        """)
    }
    
    func testProducts() {
        let expected = """
            products: [
                .executable(name: "exec", targets: ["MyLib"]),
                .library(name: "Lib", targets: ["Core"]),
                .library(name: "Static", type: .static, targets: ["MyLib"]),
                .library(name: "Dynamic", type: .dynamic, targets: ["Core"]),
            ]
        """
            
        IceAssertEqual(write4_0 { $0.addProducts(to: &$1) }, expected)
        IceAssertEqual(write4_2 { $0.addProducts(to: &$1) }, expected)
        IceAssertEqual(write5_0 { $0.addProducts(to: &$1) }, expected)
    }
    
    func testDependencies() {
        IceAssertEqual(write4_0 { $0.addDependencies(to: &$1) }, """
            dependencies: [
                .package(url: "https://github.com/jakeheis/SwiftCLI", .branch("swift4")),
                .package(url: "https://github.com/jakeheis/Spawn", .exact("0.0.4")),
                .package(url: "https://github.com/jakeheis/Flock", .revision("c57454ce053821d2fef8ad25d8918ae83506810c")),
                .package(url: "https://github.com/jakeheis/FlockCLI", from: "4.1.0"),
                .package(url: "https://github.com/jakeheis/FileKit", .upToNextMinor(from: "2.1.3")),
                .package(url: "https://github.com/jakeheis/Shout", "0.6.4"..<"0.6.8"),
            ]
        """)
        
        let expected = """
            dependencies: [
                .package(url: "https://github.com/jakeheis/SwiftCLI", .branch("swift4")),
                .package(url: "https://github.com/jakeheis/Spawn", .exact("0.0.4")),
                .package(url: "https://github.com/jakeheis/Flock", .revision("c57454ce053821d2fef8ad25d8918ae83506810c")),
                .package(url: "https://github.com/jakeheis/FlockCLI", from: "4.1.0"),
                .package(url: "https://github.com/jakeheis/FileKit", .upToNextMinor(from: "2.1.3")),
                .package(url: "https://github.com/jakeheis/Shout", "0.6.4"..<"0.6.8"),
                .package(path: "/Projects/PathKit"),
            ]
        """
        
        IceAssertEqual(write4_2 { $0.addDependencies(to: &$1) }, expected)
        IceAssertEqual(write5_0 { $0.addDependencies(to: &$1) }, expected)
    }
    
    func testTargets() throws {
        IceAssertEqual(write4_0 { $0.addTargets(to: &$1) }, """
            targets: [
                .target(name: "CLI", dependencies: ["Core", .product(name: "FileKit")]),
                .testTarget(name: "CLITests", dependencies: [.target(name: "CLI"), "Core"]),
                .target(name: "Core", dependencies: [], path: "Sources/Diff", exclude: ["ignore.swift"]),
                .target(name: "Exclusive", dependencies: ["Core", .product(name: "FlockKit", package: "Flock")], sources: ["only.swift"], publicHeadersPath: "headers.h"),
            ]
        """)
        
        IceAssertEqual(write4_2 { $0.addTargets(to: &$1) }, """
            targets: [
                .target(name: "CLI", dependencies: ["Core", .product(name: "FileKit")]),
                .testTarget(name: "CLITests", dependencies: [.target(name: "CLI"), "Core"]),
                .target(name: "Core", dependencies: [], path: "Sources/Diff", exclude: ["ignore.swift"]),
                .target(name: "Exclusive", dependencies: ["Core", .product(name: "FlockKit", package: "Flock")], sources: ["only.swift"], publicHeadersPath: "headers.h"),
                .systemLibrary(name: "Clibssh2", path: "aPath", pkgConfig: "pc", providers: [
                    .apt(["third", "fourth"]),
                    .brew(["over", "there"]),
                ]),
            ]
        """)
        
        IceAssertEqual(write5_0 { $0.addTargets(to: &$1) }, """
            targets: [
                .target(name: "CLI", dependencies: ["Core", .product(name: "FileKit")]),
                .testTarget(name: "CLITests", dependencies: [.target(name: "CLI"), "Core"]),
                .target(name: "Core", dependencies: [], path: "Sources/Diff", exclude: ["ignore.swift"]),
                .target(name: "Exclusive", dependencies: ["Core", .product(name: "FlockKit", package: "Flock")], sources: ["only.swift"], publicHeadersPath: "headers.h"),
                .systemLibrary(name: "Clibssh2", path: "aPath", pkgConfig: "pc", providers: [
                    .apt(["third", "fourth"]),
                    .brew(["over", "there"]),
                ]),
                .target(name: "Settings", dependencies: [], cSettings: [
                    .define("FOO"),
                ], cxxSettings: [
                    .headerSearchPath("path", .when()),
                ], swiftSettings: [
                    .unsafeFlags(["f1", "f2"], .when(platforms: [.macOS])),
                ], linkerSettings: [
                    .linkedLibrary("libz", .when(platforms: [.linux], configuration: .release)),
                ]),
            ]
        """)
    }
    
    func testProviders() {
        let expected = """
            providers: [
                .apt(["first", "second"]),
                .brew(["this", "that"]),
            ]
        """
        
        IceAssertEqual(write4_0 { $0.addProviders(to: &$1) }, expected)
        IceAssertEqual(write4_2 { $0.addProviders(to: &$1) }, expected)
        IceAssertEqual(write5_0 { $0.addProviders(to: &$1) }, expected)
    }
    
    func testSwiftLanguageVersions() throws {
        IceAssertEqual(write4_0 { $0.addSwiftLanguageVersions(to: &$1) }, """
            swiftLanguageVersions: [3, 4]
        """)
        
        let expected = """
            swiftLanguageVersions: [.v3, .v4, .v4_2]
        """
        IceAssertEqual(write4_2 { $0.addSwiftLanguageVersions(to: &$1) }, expected)
        IceAssertEqual(write5_0 { $0.addSwiftLanguageVersions(to: &$1) }, expected)
    }
    
    func testCLanguageStandard() {
        let expected = """
            cLanguageStandard: .iso9899_199409
        """
        
        IceAssertEqual(write4_0 { $0.addCLangaugeStandard(to: &$1) }, expected)
        IceAssertEqual(write4_2 { $0.addCLangaugeStandard(to: &$1) }, expected)
        IceAssertEqual(write5_0 { $0.addCLangaugeStandard(to: &$1) }, expected)
    }
    
    func testCxxLanguageStandard() {
        let expected = """
            cxxLanguageStandard: .gnucxx1z
        """
        
        IceAssertEqual(write4_0 { $0.addCxxLangaugeStandard(to: &$1) }, expected)
        IceAssertEqual(write4_2 { $0.addCxxLangaugeStandard(to: &$1) }, expected)
        IceAssertEqual(write5_0 { $0.addCxxLangaugeStandard(to: &$1) }, expected)
    }
    
    func testCanWrite() {
        let full4_0 = Fixtures.package4_0.convertToModern()
        XCTAssertTrue(Version4_0Writer(package: full4_0, toolsVersion: .v4).canWrite())
        XCTAssertTrue(Version4_2Writer(package: full4_0, toolsVersion: .v4_2).canWrite())
        XCTAssertTrue(Version5_0Writer(package: full4_0, toolsVersion: .v5).canWrite())
        
        let full4_2 = Fixtures.package4_2.convertToModern()
        XCTAssertFalse(Version4_0Writer(package: full4_2, toolsVersion: .v4).canWrite())
        XCTAssertTrue(Version4_2Writer(package: full4_2, toolsVersion: .v4_2).canWrite())
        XCTAssertTrue(Version5_0Writer(package: full4_2, toolsVersion: .v5).canWrite())
        
        let full5_0 = Fixtures.package5_0
        XCTAssertFalse(Version4_0Writer(package: full5_0, toolsVersion: .v4).canWrite())
        XCTAssertFalse(Version4_2Writer(package: full5_0, toolsVersion: .v4_2).canWrite())
        XCTAssertTrue(Version5_0Writer(package: full5_0, toolsVersion: .v5).canWrite())
        
        // 4.2 additions
        
        var localDep = full4_0 // local dependency supported 4.2 on
        localDep.dependencies = full4_2.dependencies
        XCTAssertFalse(Version4_0Writer(package: localDep, toolsVersion: .v4).canWrite())
        XCTAssertTrue(Version4_2Writer(package: localDep, toolsVersion: .v4_2).canWrite())
        XCTAssertTrue(Version5_0Writer(package: localDep, toolsVersion: .v5).canWrite())
        
        var systemTarget = full4_0 // system library target supported 4.2 on
        systemTarget.targets = full4_2.targets
        XCTAssertFalse(Version4_0Writer(package: systemTarget, toolsVersion: .v4).canWrite())
        XCTAssertTrue(Version4_2Writer(package: systemTarget, toolsVersion: .v4_2).canWrite())
        XCTAssertTrue(Version5_0Writer(package: systemTarget, toolsVersion: .v5).canWrite())
        
        var swiftLangVersions = full4_0 // swift langauge minor versions supported 4.2 on
        swiftLangVersions.swiftLanguageVersions = full4_2.swiftLanguageVersions
        XCTAssertFalse(Version4_0Writer(package: swiftLangVersions, toolsVersion: .v4).canWrite())
        XCTAssertTrue(Version4_2Writer(package: swiftLangVersions, toolsVersion: .v4_2).canWrite())
        XCTAssertTrue(Version5_0Writer(package: swiftLangVersions, toolsVersion: .v5).canWrite())
        
        // 5.0 additions
        
        var buildSettings = full4_2 // target build settings supported 5.0 on
        buildSettings.targets = full5_0.targets
        XCTAssertFalse(Version4_0Writer(package: buildSettings, toolsVersion: .v4).canWrite())
        XCTAssertFalse(Version4_2Writer(package: buildSettings, toolsVersion: .v4_2).canWrite())
        XCTAssertTrue(Version5_0Writer(package: buildSettings, toolsVersion: .v5).canWrite())
        
        var platforms = full4_2
        platforms.platforms = full5_0.platforms
        XCTAssertFalse(Version4_0Writer(package: platforms, toolsVersion: .v4).canWrite())
        XCTAssertFalse(Version4_2Writer(package: platforms, toolsVersion: .v4_2).canWrite())
        XCTAssertTrue(Version5_0Writer(package: platforms, toolsVersion: .v5).canWrite())
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
    
    private func write4_0(_ run: (Version4_0Writer, inout FunctionCallComponent) throws -> ()) rethrows -> String {
        return try withWriter(.v4, Fixtures.package4_0.convertToModern(), run)
    }
    
    private func write4_2(_ run: (Version4_2Writer, inout FunctionCallComponent) throws -> ()) rethrows -> String {
        return try withWriter(.v4_2, Fixtures.package4_2.convertToModern(), run)
    }
    
    private func write5_0(_ run: (Version4_2Writer, inout FunctionCallComponent) throws -> ()) rethrows -> String {
        return try withWriter(.v5, Fixtures.package5_0, run)
    }
    
}
