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
        
        let result = icebox.run("add", "jakeheis/Regex", "-n")
        IceAssertEqual(result.exitStatus, 0)
        IceAssertEqual(result.stderr, "")
        IceAssertEqual(result.stdout, """
        Fetch https://github.com/jakeheis/Regex
        Clone https://github.com/jakeheis/Regex
        Resolve https://github.com/jakeheis/Regex at 1.2.0
        
        """)
        
        IceAssertEqual(icebox.fileContents("Package.swift"), """
        // swift-tools-version:4.0
        // Managed by ice

        import PackageDescription

        let package = Package(
            name: "Lib",
            products: [
                .library(name: "Lib", targets: ["Lib"]),
            ],
            dependencies: [
                .package(url: "https://github.com/jakeheis/Regex", from: "1.2.0"),
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
        
        let result = icebox.run("add", "jakeheis/Regex", "-t", "Lib")
        IceAssertEqual(result.exitStatus, 0)
        IceAssertEqual(result.stderr, "")
        IceAssertEqual(result.stdout, """
        Fetch https://github.com/jakeheis/Regex
        Clone https://github.com/jakeheis/Regex
        Resolve https://github.com/jakeheis/Regex at 1.2.0
        
        """)
        
        IceAssertEqual(icebox.fileContents("Package.swift"), """
        // swift-tools-version:4.0
        // Managed by ice

        import PackageDescription

        let package = Package(
            name: "Lib",
            products: [
                .library(name: "Lib", targets: ["Lib"]),
            ],
            dependencies: [
                .package(url: "https://github.com/jakeheis/Regex", from: "1.2.0"),
            ],
            targets: [
                .target(name: "Lib", dependencies: ["Regex"]),
                .testTarget(name: "LibTests", dependencies: ["Lib"]),
            ]
        )

        """)
    }
    
    func testVersionedAdd() {
        let icebox = IceBox(template: .lib)
        
        let result = icebox.run("add", "jakeheis/Regex", "--from=1.1.0", "-n")
        IceAssertEqual(result.exitStatus, 0)
        IceAssertEqual(result.stderr, "")
        IceAssertEqual(result.stdout, """
        Fetch https://github.com/jakeheis/Regex
        Clone https://github.com/jakeheis/Regex
        Resolve https://github.com/jakeheis/Regex at 1.2.0
        
        """)
        
        IceAssertEqual(icebox.fileContents("Package.swift"), """
        // swift-tools-version:4.0
        // Managed by ice

        import PackageDescription

        let package = Package(
            name: "Lib",
            products: [
                .library(name: "Lib", targets: ["Lib"]),
            ],
            dependencies: [
                .package(url: "https://github.com/jakeheis/Regex", from: "1.1.0"),
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
        
        let result = icebox.run("add", "jakeheis/Regex")
        IceAssertEqual(result.exitStatus, 0)
        IceAssertEqual(result.stderr, "")
        
        result.assertStdout { (t) in
            t.equals("Fetch https://github.com/jakeheis/SwiftCLI")
            t.equals("Fetch https://github.com/jakeheis/Regex")
            t.equalsInAnyOrder([
                "Clone https://github.com/jakeheis/Regex",
                "Resolve https://github.com/jakeheis/Regex at 1.2.0",
                "Clone https://github.com/jakeheis/SwiftCLI",
                "Resolve https://github.com/jakeheis/SwiftCLI at 4.1.2"
            ])
            t.empty()
            t.done()
        }
        
        IceAssertEqual(icebox.fileContents("Package.swift"), """
        // swift-tools-version:4.0
        // Managed by ice

        import PackageDescription

        let package = Package(
            name: "Exec",
            dependencies: [
                .package(url: "https://github.com/jakeheis/SwiftCLI", from: "4.0.3"),
                .package(url: "https://github.com/jakeheis/Regex", from: "1.2.0"),
            ],
            targets: [
                .target(name: "Exec", dependencies: ["SwiftCLI", "Regex"]),
            ]
        )

        """)
    }
    
    func testBranchAdd() {
        let icebox = IceBox(template: .lib)
        
        let result = icebox.run("add", "jakeheis/SwiftCLI", "--branch=master", "-n")
        IceAssertEqual(result.exitStatus, 0)
        IceAssertEqual(result.stderr, "")
        IceAssertEqual(result.stdout, """
        Fetch https://github.com/jakeheis/SwiftCLI
        Clone https://github.com/jakeheis/SwiftCLI
        Resolve https://github.com/jakeheis/SwiftCLI at master
        
        """)
        
        IceAssertEqual(icebox.fileContents("Package.swift"), """
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
        IceAssertEqual(result.exitStatus, 0)
        IceAssertEqual(result.stderr, "")
        IceAssertEqual(result.stdout, """
        Fetch https://github.com/jakeheis/SwiftCLI
        Clone https://github.com/jakeheis/SwiftCLI
        Resolve https://github.com/jakeheis/SwiftCLI at 51ba542611878b2e64e82467b895fdf4240ec32e
        
        """)
        
        IceAssertEqual(icebox.fileContents("Package.swift"), """
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
        IceAssertEqual(result.exitStatus, 0)
        IceAssertEqual(result.stderr, "")
        result.assertStdout { (t) in
            t.equalsInAnyOrder([
                "Fetch https://github.com/jakeheis/SwiftCLI",
                "Fetch https://github.com/jakeheis/IceLibTest",
                "Clone https://github.com/jakeheis/IceLibTest",
                "Resolve https://github.com/jakeheis/IceLibTest at 1.0.0",
                "Clone https://github.com/jakeheis/SwiftCLI",
                "Resolve https://github.com/jakeheis/SwiftCLI at 4.1.2"
            ])
            t.empty()
            t.done()
        }
        
        IceAssertEqual(icebox.fileContents("Package.swift"), """
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
