//
//  NewTests.swift
//  CLITests
//
//  Created by Jake Heiser on 9/13/17.
//

import TestingUtilities
import XCTest

class NewTests: XCTestCase {
    
    func testLib() {
        let icebox = IceBox(template: .empty)
        
        let result = icebox.run("new", "MyNewLib", "--lib")
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        
        Differentiate.byVersion(swift4_1AndAbove: {
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

            Run: cd MyNewLib && ice build
            
            
            """)
        }, swift4_0AndAbove: {
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
            
            Run: cd MyNewLib && ice build
            
            
            """)
        })
        
        XCTAssertTrue(icebox.fileExists("MyNewLib"))
        XCTAssertTrue(icebox.fileExists("MyNewLib/Package.swift"))
    }
    
    func testExec() {
        let icebox = IceBox(template: .empty)
        
        let result = icebox.run("new", "MyNewExec", "--exec")
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        
        Differentiate.byVersion(swift4_2AndAbove: {
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

            Run: cd MyNewExec && ice build
            
            
            """)
        }, swift4_0AndAbove: {
            XCTAssertEqual(result.stdout, """
            
            Creating executable package: MyNewExec

                create Package.swift
                create README.md
                create .gitignore
                create Sources/
                create Sources/MyNewExec/main.swift
                create Tests/

            Run: cd MyNewExec && ice build
            
            
            """)
        })
        
        XCTAssertTrue(icebox.fileExists("MyNewExec"))
        XCTAssertTrue(icebox.fileExists("MyNewExec/Package.swift"))
    }
    
}
