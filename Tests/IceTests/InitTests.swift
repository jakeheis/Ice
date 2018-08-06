//
//  InitTests.swift
//  CLITests
//
//  Created by Jake Heiser on 9/13/17.
//

import Foundation
import TestingUtilities
import XCTest

class InitTests: XCTestCase {
    
    static var allTests = [
        ("testLib", testLib),
        ("testExec", testExec),
    ]
    
    func testLib() {
        let icebox = IceBox(template: .empty)
        icebox.createDirectory(path: "MyNewLib")
        
        let result = icebox.run("init", "--lib", configure: { $0.currentDirectoryPath += "/MyNewLib" })
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        
        differentiatedAssertEquality(result.stdout, swift4_1AndAbove: """
        
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
        
        
        """, swift4_0AndAbove: """
        
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

        Run: ice build
        
        
        """)
        
        XCTAssertTrue(icebox.fileExists("MyNewLib/Package.swift"))
    }
    
    func testExec() {
        let icebox = IceBox(template: .empty)
        icebox.createDirectory(path: "MyNewExec")
        
        let result = icebox.run("init", "--exec", configure: { $0.currentDirectoryPath += "/MyNewExec" })
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        
        differentiatedAssertEquality(result.stdout, swift4_2AndAbove: """
        
        Creating executable package: MyNewExec

            create Package.swift
            create README.md
            create .gitignore
            create Sources/
            create Sources/MyNewExec/main.swift
            create Tests/
            create Tests/LinuxMain.swift
            create Tests/MyNewExecTests/
            create Tests/MyNewExecTests/MyNewExecTests.swift
            create Tests/MyNewExecTests/XCTestManifests.swift

        Run: ice build
        
        
        """, swift4_0AndAbove: """
        
        Creating executable package: MyNewExec

            create Package.swift
            create README.md
            create .gitignore
            create Sources/
            create Sources/MyNewExec/main.swift
            create Tests/

        Run: ice build
        
        
        """)
        
        XCTAssertTrue(icebox.fileExists("MyNewExec/Package.swift"))
    }
    
}
