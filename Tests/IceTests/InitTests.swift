//
//  InitTests.swift
//  CLITests
//
//  Created by Jake Heiser on 9/13/17.
//

import XCTest
import Foundation

class InitTests: XCTestCase {
    
    static var allTests = [
        ("testLib", testLib),
        ("testExec", testExec),
    ]
    
    func testLib() {
        let result = Runner.execute(args: ["init", "--lib"], dir: "MyNewLib", sandboxSetup: {
            createSandboxDirectory(path: "MyNewLib")
        })
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        XCTAssertEqual(result.stdout, """
        
        Creating library package: MyNewLib

            create Package.swift
            create README.md
            create .gitignore
            create Sources/
            create Sources/MyNewLib/MyNewLib.swift
            create Tests/
            create Tests/LinuxMain.swift
            create Tests/MyNewLibTests/
            create Tests/MyNewLibTests/MyNewLibTests.swift
            create Tests/MyNewLibTests/XCTestManifests.swift

        Run: ice build
        
        
        """)
        
        XCTAssertTrue(sandboxFileExists(path: "MyNewLib/Package.swift"))
    }
    
    func testExec() {
        let result = Runner.execute(args: ["init", "--exec"], dir: "MyNewExec", sandboxSetup: {
            createSandboxDirectory(path: "MyNewExec")
        })
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        XCTAssertEqual(result.stdout, """
        
        Creating executable package: MyNewExec

            create Package.swift
            create README.md
            create .gitignore
            create Sources/
            create Sources/MyNewExec/main.swift
            create Tests/

        Run: ice build
        
        
        """)
        
        XCTAssertTrue(sandboxFileExists(path: "MyNewExec/Package.swift"))
    }
    
}
