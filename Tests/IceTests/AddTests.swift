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
        let result = Runner.execute(args: ["add", "jakeheis/Spawn", "-n"], sandbox: .lib)
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        XCTAssertEqual(result.stdout, """
        Fetch https://github.com/jakeheis/Spawn
        Clone https://github.com/jakeheis/Spawn
        Resolve https://github.com/jakeheis/Spawn at 0.0.6
        
        """)
        
        XCTAssertEqual(
            sandboxedFileContents("Package.swift"),
            """
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
        let result = Runner.execute(args: ["add", "jakeheis/Spawn", "-t", "Lib"], sandbox: .lib)
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        XCTAssertEqual(result.stdout, """
        Fetch https://github.com/jakeheis/Spawn
        Clone https://github.com/jakeheis/Spawn
        Resolve https://github.com/jakeheis/Spawn at 0.0.6
        
        """)
        
        XCTAssertEqual(
            sandboxedFileContents("Package.swift"),
            """
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
        let result = Runner.execute(args: ["add", "jakeheis/Spawn", "--version=0.0.5", "-n"], sandbox: .lib)
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        XCTAssertEqual(result.stdout, """
        Fetch https://github.com/jakeheis/Spawn
        Clone https://github.com/jakeheis/Spawn
        Resolve https://github.com/jakeheis/Spawn at 0.0.6
        
        """)
        
        XCTAssertEqual(
            sandboxedFileContents("Package.swift"),
            """
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
        let result = Runner.execute(args: ["add", "jakeheis/Spawn"], sandbox: .exec)
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        XCTAssertEqual(result.stdout, """
        Update https://github.com/jakeheis/SwiftCLI
        Fetch https://github.com/jakeheis/Spawn
        Clone https://github.com/jakeheis/Spawn
        Resolve https://github.com/jakeheis/Spawn at 0.0.6
        
        """)
        
        XCTAssertEqual(sandboxedFileContents("Package.swift"), """
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
        let result = Runner.execute(args: ["add", "jakeheis/SwiftCLI", "--branch=master", "-n"], sandbox: .lib)
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        XCTAssertEqual(result.stdout, """
        Fetch https://github.com/jakeheis/SwiftCLI
        Clone https://github.com/jakeheis/SwiftCLI
        Resolve https://github.com/jakeheis/SwiftCLI at master
        
        """)
        
        XCTAssertEqual(sandboxedFileContents("Package.swift"), """
        // swift-tools-version:4.0
        // Managed by ice

        import PackageDescription

        let package = Package(
            name: "Lib",
            products: [
                .library(name: "Lib", targets: ["Lib"]),
            ],
            dependencies: [
                .package(url: "https://github.com/jakeheis/SwiftCLI", .branchItem("master")),
            ],
            targets: [
                .target(name: "Lib", dependencies: []),
                .testTarget(name: "LibTests", dependencies: ["Lib"]),
            ]
        )

        """)
    }
    
    func testSHAAdd() {
        let result = Runner.execute(args: ["add", "jakeheis/SwiftCLI", "--sha=51ba542611878b2e64e82467b895fdf4240ec32e", "-n"], sandbox: .lib)
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        XCTAssertEqual(result.stdout, """
        Fetch https://github.com/jakeheis/SwiftCLI
        Clone https://github.com/jakeheis/SwiftCLI
        Resolve https://github.com/jakeheis/SwiftCLI at 51ba542611878b2e64e82467b895fdf4240ec32e
        
        """)
        
        XCTAssertEqual(sandboxedFileContents("Package.swift"), """
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
        let result = Runner.execute(args: ["add", "jakeheis/IceLibTest"], sandbox: .exec)
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        XCTAssertEqual(result.stdout, """
        Update https://github.com/jakeheis/SwiftCLI
        Fetch https://github.com/jakeheis/IceLibTest
        Clone https://github.com/jakeheis/IceLibTest
        Resolve https://github.com/jakeheis/IceLibTest at 1.0.0
        
        """)
        
        XCTAssertEqual(sandboxedFileContents("Package.swift"), """
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
