//
//  PackageDataTests.swift
//  IceKitTests
//
//  Created by Jake Heiser on 7/29/18.
//

@testable import IceKit
import PathKit
import SwiftCLI
import TestingUtilities
import XCTest

class PackageDataTests: XCTestCase {
    
    let packagePath = Path.current + "Package.swift"
    
    func test4_0() throws {
        let icebox = IceBox(template: .json)
        
        let data: Data = icebox.fileContents("full_4_0.json")!
        let parsed = try JSONDecoder().decode(PackageDataV4_0.self, from: data)
        let package = Package(data: parsed.convertToModern(), toolsVersion: .v4, path: packagePath, config: mockConfig)
        
        XCTAssertEqual(package.toolsVersion, SwiftToolsVersion(major: 4, minor: 0, patch: 0))
        XCTAssertEqual(package.dirty, false)
        
        let captureStream = CaptureStream()
        try package.write(to: captureStream)
        captureStream.closeWrite()
        
        XCTAssertEqual(captureStream.readAll(), """
        // swift-tools-version:4.0
        // Managed by ice

        import PackageDescription

        let package = Package(
            name: "Gr4",
            products: [
                .executable(name: "Gr4", targets: ["Gr4"]),
                .library(name: "Gr5lib", targets: ["Gr5"]),
                .library(name: "Gr5dynamic", type: .dynamic, targets: ["Gr5"]),
                .library(name: "Gr5static", type: .static, targets: ["Gr5"]),
            ],
            dependencies: [
                .package(url: "https://github.com/kylef/PathKit", from: "0.9.1"),
                .package(url: "https://github.com/onevcat/Rainbow", .branch("master")),
                .package(url: "https://github.com/sharplet/Regex", .revision("0b18d20fbc9c279cf6493dd0fd431ebb40a7741b")),
                .package(url: "https://github.com/jakeheis/SwiftCLI", .exact("5.1.3")),
            ],
            targets: [
                .target(name: "Gr4", dependencies: ["PathKit"], exclude: ["notthis.swift"], sources: ["main.swift"], publicHeadersPath: "headers"),
                .target(name: "Gr5", dependencies: [.target(name: "Gr4"), .product(name: "PathKit"), "Rainbow", .product(name: "SwiftCLI", package: "SwiftCLI")]),
                .testTarget(name: "Gr5Tests", dependencies: ["Gr5"]),
            ],
            swiftLanguageVersions: [3, 4],
            cLanguageStandard: .c90,
            cxxLanguageStandard: .cxx98
        )

        """)
    }
    
    func test4_2() throws {
        let icebox = IceBox(template: .json)
        
        let data: Data = icebox.fileContents("full_4_2.json")!
        let parsed = try JSONDecoder().decode(PackageDataV4_2.self, from: data)
        let package = Package(data: parsed.convertToModern(), toolsVersion: .v4_2, path: packagePath, config: mockConfig)
        
        XCTAssertEqual(package.toolsVersion, SwiftToolsVersion(major: 4, minor: 2, patch: 0))
        XCTAssertEqual(package.dirty, false)
        
        let captureStream = CaptureStream()
        try package.write(to: captureStream)
        captureStream.closeWrite()
        
        XCTAssertEqual(captureStream.readAll(), """
        // swift-tools-version:4.2
        // Managed by ice

        import PackageDescription

        let package = Package(
            name: "Ice",
            pkgConfig: "iceConfig",
            providers: [
                .brew(["brewPackage"]),
                .apt(["aptItem", "secondItem"]),
            ],
            products: [
                .executable(name: "ice", targets: ["Ice"]),
                .library(name: "IceKit", targets: ["IceKit"]),
                .library(name: "IceKitStatic", type: .static, targets: ["IceKit"]),
                .library(name: "IceKitDynamic", type: .dynamic, targets: ["IceKit"]),
            ],
            dependencies: [
                .package(url: "https://github.com/kylef/PathKit", from: "0.9.1"),
                .package(url: "https://github.com/onevcat/Rainbow", .branch("master")),
                .package(url: "https://github.com/sharplet/Regex", .revision("abcde")),
                .package(url: "https://github.com/jakeheis/SwiftCLI", .exact("5.1.3")),
                .package(path: "/Projects/FakeLocal"),
            ],
            targets: [
                .target(name: "Ice", dependencies: ["IceCLI"], path: "non-standard-path", exclude: ["notthis.swift"], sources: ["this.swift"], publicHeadersPath: "headers"),
                .target(name: "IceCLI", dependencies: [.target(name: "IceKit"), .product(name: "PathKit"), "Rainbow", .product(name: "CLI", package: "SwiftCLI"), "FakeLocal"]),
                .target(name: "IceKit", dependencies: ["PathKit", "Rainbow", "Regex", "SwiftCLI"]),
                .testTarget(name: "IceKitTests", dependencies: ["IceKit", "PathKit", "SwiftCLI"]),
                .systemLibrary(name: "CZLib", pkgConfig: "pc", providers: [
                    .apt(["hey"]),
                ]),
            ],
            swiftLanguageVersions: [.v4, .v4_2],
            cLanguageStandard: .c90,
            cxxLanguageStandard: .cxx98
        )

        """)
    }
    
    func test5_0() throws {
        let icebox = IceBox(template: .json)
        
        let data: Data = icebox.fileContents("full_5_0.json")!
        let parsed = try JSONDecoder().decode(PackageDataV5_0.self, from: data)
        let package = Package(data: parsed, toolsVersion: .v5, path: packagePath, config: mockConfig)
        
        XCTAssertEqual(package.toolsVersion, SwiftToolsVersion(major: 5, minor: 0, patch: 0))
        XCTAssertEqual(package.dirty, false)
        
        let captureStream = CaptureStream()
        try package.write(to: captureStream)
        captureStream.closeWrite()
        
        XCTAssertEqual(captureStream.readAll(), """
        // swift-tools-version:5.0
        // Managed by ice

        import PackageDescription

        let package = Package(
            name: "Ice",
            pkgConfig: "iceConfig",
            providers: [
                .brew(["brewPackage"]),
                .apt(["aptItem", "secondItem"]),
            ],
            products: [
                .executable(name: "ice", targets: ["Ice"]),
                .library(name: "IceKit", targets: ["IceKit"]),
                .library(name: "IceKitStatic", type: .static, targets: ["IceKit"]),
                .library(name: "IceKitDynamic", type: .dynamic, targets: ["IceKit"]),
            ],
            dependencies: [
                .package(url: "https://github.com/kylef/PathKit", from: "0.9.1"),
                .package(url: "https://github.com/onevcat/Rainbow", .branch("master")),
                .package(url: "https://github.com/sharplet/Regex", .revision("abcde")),
                .package(url: "https://github.com/jakeheis/SwiftCLI", .exact("5.1.3")),
                .package(path: "/Projects/FakeLocal"),
            ],
            targets: [
                .target(name: "Ice", dependencies: ["IceCLI"], path: "non-standard-path", exclude: ["notthis.swift"], sources: ["this.swift"], publicHeadersPath: "headers", cSettings: [
                    .define("BAR"),
                    .headerSearchPath("path/relative/to/my/target"),
                ], cxxSettings: [
                    .define("FOO"),
                ], swiftSettings: [
                    .define("API_VERSION_5"),
                ], linkerSettings: [
                    .linkedLibrary("libssh2"),
                    .linkedLibrary("openssl", .when(platforms: [.linux])),
                    .linkedFramework("CoreData", .when(platforms: [.macOS], configuration: .debug)),
                    .unsafeFlags(["-L/path/to/my/library", "-use-ld=gold"], .when(platforms: [.linux])),
                ]),
                .target(name: "IceCLI", dependencies: [.target(name: "IceKit"), .product(name: "PathKit"), "Rainbow", .product(name: "CLI", package: "SwiftCLI"), "FakeLocal"]),
                .target(name: "IceKit", dependencies: ["PathKit", "Rainbow", "Regex", "SwiftCLI"]),
                .testTarget(name: "IceKitTests", dependencies: ["IceKit", "PathKit", "SwiftCLI"]),
                .systemLibrary(name: "CZLib", pkgConfig: "pc", providers: [
                    .apt(["hey"]),
                ]),
            ],
            swiftLanguageVersions: [.v4, .v4_2],
            cLanguageStandard: .c90,
            cxxLanguageStandard: .cxx98
        )

        """)
    }
    
    func testModernize4_0() throws {
        let modernized = Fixtures.package4_0.convertToModern()
        
        var expected = Fixtures.package5_0
        expected.targets.removeLast() // Remove settings target
        expected.targets.removeLast() // Remove system target
        expected.dependencies.removeLast() // Remove local dependency
        expected.swiftLanguageVersions?.removeLast() // Remove non-integer version
        
        XCTAssertEqual(modernized, expected)
    }
    
    func testModernize4_2() {
        let modernized = Fixtures.package4_2.convertToModern()
        
        var expected = Fixtures.package5_0
        expected.targets.removeLast() // Remove settings target
        
        XCTAssertEqual(modernized, expected)
    }

    func testSwiftToolsVersion() {
        let fourTwo = SwiftToolsVersion(major: 4, minor: 2, patch: 0)
        
        XCTAssertEqual(fourTwo, .v4_2)
        XCTAssertNotEqual(fourTwo, .v4)
        
        XCTAssertGreaterThan(fourTwo, .v4)
        
        XCTAssertEqual(fourTwo.description, "4.2")
        XCTAssertEqual(fourTwo, SwiftToolsVersion("4.2.0"))
        XCTAssertEqual(fourTwo, SwiftToolsVersion("4.2"))
    }
    
}
