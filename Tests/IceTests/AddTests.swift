//
//  AddTests.swift
//  CLITests
//
//  Created by Jake Heiser on 9/13/17.
//

import TestingUtilities
import XCTest

class AddTests: XCTestCase {

    func testBasicAdd() {
        let icebox = IceBox(template: .lib)
        
        icebox.execute(with: "version")
        
        let result = icebox.run("add", "jakeheis/Spawn", "-n")
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        XCTAssertEqual(result.stdout, """
        Fetch https://github.com/jakeheis/Spawn
        Clone https://github.com/jakeheis/Spawn
        Resolve https://github.com/jakeheis/Spawn at 0.0.6
        
        """)
        
        XCTAssertEqual(icebox.fileContents("Package.swift"), """
        // swift-tools-version:4.0
        // Managed by ice

        import PackageDescription

        let package = Package(
            name: "Lib",
            products: [
                .library(name: "Lib", targets: ["Lib"]),
            ],
            dependencies: [
                .package(url: "https://github.com/jakeheis/Spawn", from: "0.0.6"),
            ],
            targets: [
                .target(name: "Lib", dependencies: []),
                .testTarget(name: "LibTests", dependencies: ["Lib"]),
            ]
        )

        """)
    }
    
    func testTargetAdd() {
        let icebox = IceBox(template: .lib)
        
        let result = icebox.run("add", "jakeheis/Spawn", "-t", "Lib")
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        XCTAssertEqual(result.stdout, """
        Fetch https://github.com/jakeheis/Spawn
        Clone https://github.com/jakeheis/Spawn
        Resolve https://github.com/jakeheis/Spawn at 0.0.6
        
        """)
        
        XCTAssertEqual(icebox.fileContents("Package.swift"), """
        // swift-tools-version:4.0
        // Managed by ice

        import PackageDescription

        let package = Package(
            name: "Lib",
            products: [
                .library(name: "Lib", targets: ["Lib"]),
            ],
            dependencies: [
                .package(url: "https://github.com/jakeheis/Spawn", from: "0.0.6"),
            ],
            targets: [
                .target(name: "Lib", dependencies: ["Spawn"]),
                .testTarget(name: "LibTests", dependencies: ["Lib"]),
            ]
        )

        """)
    }
    
    func testVersionedAdd() {
        let icebox = IceBox(template: .lib)
        
        let result = icebox.run("add", "jakeheis/Spawn", "--version=0.0.5", "-n")
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        XCTAssertEqual(result.stdout, """
        Fetch https://github.com/jakeheis/Spawn
        Clone https://github.com/jakeheis/Spawn
        Resolve https://github.com/jakeheis/Spawn at 0.0.6
        
        """)
        
        XCTAssertEqual(icebox.fileContents("Package.swift"), """
        // swift-tools-version:4.0
        // Managed by ice

        import PackageDescription

        let package = Package(
            name: "Lib",
            products: [
                .library(name: "Lib", targets: ["Lib"]),
            ],
            dependencies: [
                .package(url: "https://github.com/jakeheis/Spawn", from: "0.0.5"),
            ],
            targets: [
                .target(name: "Lib", dependencies: []),
                .testTarget(name: "LibTests", dependencies: ["Lib"]),
            ]
        )

        """)
    }
    
    func testSingleTargetAdd() {
        let icebox = IceBox(template: .exec)
        
        let result = icebox.run("add", "jakeheis/Spawn")
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        
        Differentiate.byVersion(swift4_2AndAbove: {
            result.assertStdout { (t) in
                t.equals("Fetch https://github.com/jakeheis/SwiftCLI")
                t.equals("Fetch https://github.com/jakeheis/Spawn")
                t.equalsInAnyOrder([
                    "Clone https://github.com/jakeheis/Spawn",
                    "Resolve https://github.com/jakeheis/Spawn at 0.0.6",
                    "Clone https://github.com/jakeheis/SwiftCLI",
                    "Resolve https://github.com/jakeheis/SwiftCLI at 4.1.2"
                ])
                t.empty()
                t.done()
            }
        }, swift4_1AndAbove: {
            XCTAssertEqual(result.stdout, """
            Update https://github.com/jakeheis/SwiftCLI
            Fetch https://github.com/jakeheis/Spawn
            Clone https://github.com/jakeheis/Spawn
            Resolve https://github.com/jakeheis/Spawn at 0.0.6
            
            """)
        }, swift4_0AndAbove: {
            XCTAssertEqual(result.stdout, """
            Fetch https://github.com/jakeheis/Spawn
            Update https://github.com/jakeheis/SwiftCLI
            Clone https://github.com/jakeheis/Spawn
            Resolve https://github.com/jakeheis/Spawn at 0.0.6
            
            """)
        })
        
        XCTAssertEqual(icebox.fileContents("Package.swift"), """
        // swift-tools-version:4.0
        // Managed by ice

        import PackageDescription

        let package = Package(
            name: "Exec",
            dependencies: [
                .package(url: "https://github.com/jakeheis/SwiftCLI", from: "4.0.3"),
                .package(url: "https://github.com/jakeheis/Spawn", from: "0.0.6"),
            ],
            targets: [
                .target(name: "Exec", dependencies: ["SwiftCLI", "Spawn"]),
            ]
        )

        """)
    }
    
    func testBranchAdd() {
        let icebox = IceBox(template: .lib)
        
        let result = icebox.run("add", "jakeheis/SwiftCLI", "--branch=master", "-n")
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        XCTAssertEqual(result.stdout, """
        Fetch https://github.com/jakeheis/SwiftCLI
        Clone https://github.com/jakeheis/SwiftCLI
        Resolve https://github.com/jakeheis/SwiftCLI at master
        
        """)
        
        XCTAssertEqual(icebox.fileContents("Package.swift"), """
        // swift-tools-version:4.0
        // Managed by ice

        import PackageDescription

        let package = Package(
            name: "Lib",
            products: [
                .library(name: "Lib", targets: ["Lib"]),
            ],
            dependencies: [
                .package(url: "https://github.com/jakeheis/SwiftCLI", .branch("master")),
            ],
            targets: [
                .target(name: "Lib", dependencies: []),
                .testTarget(name: "LibTests", dependencies: ["Lib"]),
            ]
        )

        """)
    }
    
    func testSHAAdd() {
        let icebox = IceBox(template: .lib)
        
        let result = icebox.run("add", "jakeheis/SwiftCLI", "--sha=51ba542611878b2e64e82467b895fdf4240ec32e", "-n")
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        XCTAssertEqual(result.stdout, """
        Fetch https://github.com/jakeheis/SwiftCLI
        Clone https://github.com/jakeheis/SwiftCLI
        Resolve https://github.com/jakeheis/SwiftCLI at 51ba542611878b2e64e82467b895fdf4240ec32e
        
        """)
        
        XCTAssertEqual(icebox.fileContents("Package.swift"), """
        // swift-tools-version:4.0
        // Managed by ice

        import PackageDescription

        let package = Package(
            name: "Lib",
            products: [
                .library(name: "Lib", targets: ["Lib"]),
            ],
            dependencies: [
                .package(url: "https://github.com/jakeheis/SwiftCLI", .revision("51ba542611878b2e64e82467b895fdf4240ec32e")),
            ],
            targets: [
                .target(name: "Lib", dependencies: []),
                .testTarget(name: "LibTests", dependencies: ["Lib"]),
            ]
        )

        """)
    }
    
    func testDifferentNamedLib() {
        let icebox = IceBox(template: .exec)
        
        let result = icebox.run("add", "jakeheis/IceLibTest")
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        
        Differentiate.byVersion(swift4_2AndAbove: {
            result.assertStdout { (t) in
                t.equals("Fetch https://github.com/jakeheis/SwiftCLI")
                t.equals("Fetch https://github.com/jakeheis/IceLibTest")
                t.equalsInAnyOrder([
                    "Clone https://github.com/jakeheis/IceLibTest",
                    "Resolve https://github.com/jakeheis/IceLibTest at 1.0.0",
                    "Clone https://github.com/jakeheis/SwiftCLI",
                    "Resolve https://github.com/jakeheis/SwiftCLI at 4.1.2"
                ])
                t.empty()
                t.done()
            }
        }, swift4_1AndAbove: {
            XCTAssertEqual(result.stdout, """
            Update https://github.com/jakeheis/SwiftCLI
            Fetch https://github.com/jakeheis/IceLibTest
            Clone https://github.com/jakeheis/IceLibTest
            Resolve https://github.com/jakeheis/IceLibTest at 1.0.0
            
            """)
        }, swift4_0AndAbove: {
            XCTAssertEqual(result.stdout, """
            Fetch https://github.com/jakeheis/IceLibTest
            Update https://github.com/jakeheis/SwiftCLI
            Clone https://github.com/jakeheis/IceLibTest
            Resolve https://github.com/jakeheis/IceLibTest at 1.0.0
            
            """)
        })
        
        XCTAssertEqual(icebox.fileContents("Package.swift"), """
        // swift-tools-version:4.0
        // Managed by ice

        import PackageDescription

        let package = Package(
            name: "Exec",
            dependencies: [
                .package(url: "https://github.com/jakeheis/SwiftCLI", from: "4.0.3"),
                .package(url: "https://github.com/jakeheis/IceLibTest", from: "1.0.0"),
            ],
            targets: [
                .target(name: "Exec", dependencies: ["SwiftCLI", "IceLib"]),
            ]
        )

        """)
    }
    
}
