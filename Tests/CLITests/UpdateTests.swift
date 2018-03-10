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
        let buildResult = Runner.execute(args: ["build"], sandbox: .exec)
        XCTAssertEqual(buildResult.exitStatus, 0)
        XCTAssertEqual(buildResult.stderr, "")
        
        let result = Runner.execute(args: ["update"], clean: false)
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        XCTAssertEqual(result.stdout, """
        Update https://github.com/jakeheis/SwiftCLI
        
        """)
    }
    
    func testUpdateSingle() {
        let buildResult = Runner.execute(args: ["build"], sandbox: .exec)
        XCTAssertEqual(buildResult.exitStatus, 0)
        XCTAssertEqual(buildResult.stderr, "")
        
        let result = Runner.execute(args: ["update", "SwiftCLI", "5.0.0"], clean: false)
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        XCTAssertEqual(result.stdout, "")
        
        XCTAssertEqual(sandboxedFileContents("Package.swift"), """
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
