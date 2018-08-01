//
//  AddTests.swift
//  CLITests
//
//  Created by Jake Heiser on 9/13/17.
//

import XCTest

class AddTests: XCTestCase {

    static var allTests = [
        ("testBasicAdd", testBasicAdd),
        ("testTargetAdd", testTargetAdd),
        ("testVersionedAdd", testVersionedAdd),
        ("testSingleTargetAdd", testSingleTargetAdd),
        ("testBranchAdd", testBranchAdd),
        ("testSHAAdd", testSHAAdd),
        ("testDifferentNamedLib", testDifferentNamedLib),
    ]
    
    func testBasicAdd() {
        let icebox = IceBox(template: .lib)
        
        let r = icebox.run("version")
        print(r.stdout!)
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
        
        #if swift(>=4.1.3)
        // Line order not deterministic
        let lines = result.stdout?.components(separatedBy: "\n") ?? []
        XCTAssertEqual(lines.count, 7)
        XCTAssertEqual(lines[0], "Fetch https://github.com/jakeheis/SwiftCLI")
        XCTAssertEqual(lines[1], "Fetch https://github.com/jakeheis/Spawn")
        XCTAssertTrue(lines.contains("Clone https://github.com/jakeheis/Spawn"))
        XCTAssertTrue(lines.contains("Resolve https://github.com/jakeheis/Spawn at 0.0.6"))
        XCTAssertTrue(lines.contains("Clone https://github.com/jakeheis/SwiftCLI"))
        XCTAssertTrue(lines.contains("Resolve https://github.com/jakeheis/SwiftCLI at 4.1.2"))
        XCTAssertEqual(lines.last, "")
        #elseif swift(>=4.1)
        XCTAssertEqual(result.stdout, """
        Update https://github.com/jakeheis/SwiftCLI
        Fetch https://github.com/jakeheis/Spawn
        Clone https://github.com/jakeheis/Spawn
        Resolve https://github.com/jakeheis/Spawn at 0.0.6
        
        """)
        #else
        XCTAssertEqual(result.stdout, """
        Fetch https://github.com/jakeheis/Spawn
        Update https://github.com/jakeheis/SwiftCLI
        Clone https://github.com/jakeheis/Spawn
        Resolve https://github.com/jakeheis/Spawn at 0.0.6
        
        """)
        #endif
        
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
        
        #if swift(>=4.1.3)
        // Line order not deterministic
        let lines = result.stdout?.components(separatedBy: "\n") ?? []
        XCTAssertEqual(lines.count, 7)
        XCTAssertEqual(lines[0], "Fetch https://github.com/jakeheis/SwiftCLI")
        XCTAssertEqual(lines[1], "Fetch https://github.com/jakeheis/IceLibTest")
        XCTAssertTrue(lines.contains("Clone https://github.com/jakeheis/IceLibTest"))
        XCTAssertTrue(lines.contains("Resolve https://github.com/jakeheis/IceLibTest at 1.0.0"))
        XCTAssertTrue(lines.contains("Clone https://github.com/jakeheis/SwiftCLI"))
        XCTAssertTrue(lines.contains("Resolve https://github.com/jakeheis/SwiftCLI at 4.1.2"))
        XCTAssertEqual(lines.last, "")
        #elseif swift(>=4.1)
        XCTAssertEqual(result.stdout, """
        Update https://github.com/jakeheis/SwiftCLI
        Fetch https://github.com/jakeheis/IceLibTest
        Clone https://github.com/jakeheis/IceLibTest
        Resolve https://github.com/jakeheis/IceLibTest at 1.0.0
        
        """)
        #else
        XCTAssertEqual(result.stdout, """
        Fetch https://github.com/jakeheis/IceLibTest
        Update https://github.com/jakeheis/SwiftCLI
        Clone https://github.com/jakeheis/IceLibTest
        Resolve https://github.com/jakeheis/IceLibTest at 1.0.0
        
        """)
        #endif
        
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
