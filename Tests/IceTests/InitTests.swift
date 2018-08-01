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
        let icebox = IceBox(template: .empty)
        icebox.createDirectory(path: "MyNewLib")
        
        let result = icebox.run("init", "--lib", configure: { $0.currentDirectoryPath += "/MyNewLib" })
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        
        #if swift(>=4.1)
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
        #else
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

        Run: ice build
        
        
        """)
        #endif
        
        XCTAssertTrue(icebox.fileExists("MyNewLib/Package.swift"))
    }
    
    func testExec() {
        let icebox = IceBox(template: .empty)
        icebox.createDirectory(path: "MyNewExec")
        
        let result = icebox.run("init", "--exec", configure: { $0.currentDirectoryPath += "/MyNewExec" })
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        
        #if swift(>=4.1.3)
        XCTAssertEqual(result.stdout, """
        
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
        
        
        """)
        #else
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
        #endif
        
        XCTAssertTrue(icebox.fileExists("MyNewExec/Package.swift"))
    }
    
}
