//
//  PackageDataTests.swift
//  IceKitTests
//
//  Created by Jake Heiser on 7/29/18.
//

@testable import IceKit
import XCTest

class PackageDataTests: XCTestCase {
    
    func testModernize4_0() throws {
        let v4_0 = PackageDataV4_0(
            name: "MyPackage",
            pkgConfig: "config",
            providers: [.init(name: "provider", values: ["provider-name"])],
            products: [.init(name: "product", product_type: "type", targets: ["targ1"], type: "library")],
            dependencies: [.init(url: "https://github.com/jakeheis/SwiftCLI", requirement: .init(version: Version(5, 0, 0)))],
            targets: [
            .init(name: "targ1", isTest: false, dependencies: [.init(name: "SwiftCLI", package: nil, type: .byname)], path: nil, exclude: [], sources: nil, publicHeadersPath: nil),
                .init(name: "targ1Tests", isTest: true, dependencies: [.init(name: "targ1", package: nil, type: .byname)], path: nil, exclude: [], sources: nil, publicHeadersPath: nil)
            ],
            swiftLanguageVersions: [3, 4],
            cLanguageStandard: "c-lang",
            cxxLanguageStandard: "c++-lang"
        )
        let modern = v4_0.convertToModern()
        
        let expectedModern = ModernPackageData(
            name: "MyPackage",
            pkgConfig: "config",
            providers: [.init(name: "provider", values: ["provider-name"])],
            products: [.init(name: "product", targets: ["targ1"], type: .library(.automatic))],
            dependencies: [.init(url: "https://github.com/jakeheis/SwiftCLI", requirement: .init(version: Version(5, 0, 0)))],
            targets: [
                .init(name: "targ1", type: .regular, dependencies: [.byName("SwiftCLI")], path: nil, exclude: [], sources: nil, publicHeadersPath: nil, pkgConfig: nil, providers: nil),
                .init(name: "targ1Tests", type: .test, dependencies: [.byName("targ1")], path: nil, exclude: [], sources: nil, publicHeadersPath: nil, pkgConfig: nil, providers: nil)
            ],
            swiftLanguageVersions: ["3", "4"],
            cLanguageStandard: "c-lang",
            cxxLanguageStandard: "c++-lang"
        )
        
        assertEqualCodings(modern, expectedModern)
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
