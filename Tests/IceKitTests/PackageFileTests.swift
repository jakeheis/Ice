//
//  PackageLoaderTests.swift
//  IceKitTests
//
//  Created by Jake Heiser on 9/11/17.
//

import Icebox
@testable import IceKit
import PathKit
import SwiftCLI
import TestingUtilities
import XCTest

class PackageLoaderTests: XCTestCase {
    
    func testFormPackagePath() {
        XCTAssertEqual(PackageFile.formPackagePath(in: .current, versionTag: nil), .current + "Package.swift")
        XCTAssertEqual(PackageFile.formPackagePath(in: .current, versionTag: "4.0"), .current + "Package@swift-4.0.swift")
        XCTAssertEqual(PackageFile.formPackagePath(in: .current, versionTag: "4.1.2"), .current + "Package@swift-4.1.2.swift")
    }
    
    func testFindPackageRoot() {
        let icebox = IceBox(template: .lib)
        
        icebox.inside {
            let root = Path.current
            
            XCTAssertEqual(PackageFile.find(in: .current)?.path.parent(), root)
            
            (root + "Sources").chdir {
                XCTAssertEqual(PackageFile.find(in: .current)?.path.parent(), root)
            }
        }
    }
    
    func testVersionedPackage() {
        let icebox = IceBox(template: .lib)
        
        icebox.createFile(path: "Package@swift-4.2.swift", contents: """
        // swift-tools-version:4.2
        // The swift-tools-version declares the minimum version of Swift required to build this package.

        import PackageDescription

        let package = Package(
            name: "Lib4_2",
            products: [
                .library(name: "Lib", targets: ["Lib"]),
            ],
            dependencies: [],
            targets: [
                .target(name: "Lib", dependencies: []),
                .testTarget(name: "LibTests", dependencies: ["Lib"]),
            ]
        )

        """)
        
        icebox.inside {
            let base = Path.current + "Package.swift"
            let specific = Path.current + "Package@swift-4.2.swift"
            
            XCTAssertEqual(PackageFile(directory: .current, compilerVersion: .v4)?.path, base)
            XCTAssertEqual(PackageFile(directory: .current, compilerVersion: .v4_2)?.path, specific)
            XCTAssertEqual(PackageFile(directory: .current, compilerVersion: .v5)?.path, base)
            XCTAssertNil(PackageFile(directory: .current + "Sources", compilerVersion: .v5))
        }
    }
    
}
