//
//  UpdateTests.swift
//  CLITests
//
//  Created by Jake Heiser on 9/25/17.
//

import TestingUtilities
import XCTest

class UpdateTests: XCTestCase {
    
    func testUpdate() {
        let icebox = IceBox(template: .exec)
        
        let buildResult = icebox.run("build")
        IceAssertEqual(buildResult.exitStatus, 0)
        IceAssertEqual(buildResult.stderr, "")
        
        let result = icebox.run("update")
        IceAssertEqual(result.exitStatus, 0)
        IceAssertEqual(result.stderr, "")
        IceAssertEqual(result.stdout, """
        Update https://github.com/jakeheis/SwiftCLI
        Resolve https://github.com/jakeheis/SwiftCLI at 4.3.2
        
        """)
    }
    
    func testUpdateSingle() {
        let icebox = IceBox(template: .exec)
        
        let buildResult = icebox.run("build")
        IceAssertEqual(buildResult.exitStatus, 0)
        IceAssertEqual(buildResult.stderr, "")
        
        let result = icebox.run("update", "SwiftCLI", "--from=5.0.0")
        IceAssertEqual(result.exitStatus, 0)
        IceAssertEqual(result.stderr, "")
        IceAssertEqual(result.stdout, "")
        
        IceAssertEqual(icebox.fileContents("Package.swift"), """
        // swift-tools-version:4.0
        // Managed by ice

        import PackageDescription

        let package = Package(
            name: "Exec",
            dependencies: [
                .package(url: "https://github.com/jakeheis/SwiftCLI", from: "5.0.0"),
            ],
            targets: [
                .target(name: "Exec", dependencies: ["SwiftCLI"]),
            ]
        )
        
        """)
    }
    
}
