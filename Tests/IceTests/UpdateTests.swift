//
//  UpdateTests.swift
//  CLITests
//
//  Created by Jake Heiser on 9/25/17.
//

import XCTest

class UpdateTests: XCTestCase {
    
    static var allTests = [
        ("testUpdate", testUpdate),
        ("testUpdateSingle", testUpdateSingle)
    ]
    
    func testUpdate() {
        let icebox = IceBox(template: .exec)
        
        let buildResult = icebox.run("build")
        XCTAssertEqual(buildResult.exitStatus, 0)
        XCTAssertEqual(buildResult.stderr, "")
        
        let result = icebox.run("update")
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        XCTAssertEqual(result.stdout, """
        Update https://github.com/jakeheis/SwiftCLI
        Resolve https://github.com/jakeheis/SwiftCLI at 4.3.2
        
        """)
    }
    
    func testUpdateSingle() {
        let icebox = IceBox(template: .exec)
        
        let buildResult = icebox.run("build")
        XCTAssertEqual(buildResult.exitStatus, 0)
        XCTAssertEqual(buildResult.stderr, "")
        
        let result = icebox.run("update", "SwiftCLI", "--version=5.0.0")
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        XCTAssertEqual(result.stdout, "")
        
        XCTAssertEqual(icebox.fileContents("Package.swift"), """
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
