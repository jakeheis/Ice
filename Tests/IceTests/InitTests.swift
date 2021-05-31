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
    
    func testLib() {
        let icebox = IceBox(template: .empty)
        icebox.createDirectory(path: "MyNewLib")
        
        let result = icebox.run("init", "--lib", configure: { $0.currentDirectoryPath += "/MyNewLib" })
        IceAssertEqual(result.exitStatus, 0)
        IceAssertEqual(result.stderr, "")
        IceAssertEqual(result.stdout, """
        
        Creating library package: MyNewLib

            create Package.swift
            create README.md
            create .gitignore
            create Sources/
            create Sources/MyNewLib/MyNewLib.swift
            create Tests/
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
        IceAssertEqual(result.exitStatus, 0)
        IceAssertEqual(result.stderr, "")
        IceAssertEqual(result.stdout, """
        
        Creating executable package: MyNewExec

            create Package.swift
            create README.md
            create .gitignore
            create Sources/
            create Sources/MyNewExec/main.swift
            create Tests/
            create Tests/MyNewExecTests/
            create Tests/MyNewExecTests/MyNewExecTests.swift

        Run: ice build
        
        
        """)
                
        XCTAssertTrue(icebox.fileExists("MyNewExec/Package.swift"))
    }
    
}
