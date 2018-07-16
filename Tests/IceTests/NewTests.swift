//
//  NewTests.swift
//  CLITests
//
//  Created by Jake Heiser on 9/13/17.
//

import XCTest

class NewTests: XCTestCase {
    
    static var allTests = [
        ("testLib", testLib),
        ("testExec", testExec),
    ]
    
    func testLib() {
        let icebox = IceBox(template: .empty)
        
        let result = icebox.run("new", "MyNewLib", "--lib")
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

        Run: cd MyNewLib && ice build
        
        
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
        
        Run: cd MyNewLib && ice build
        
        
        """)
        #endif
        
        XCTAssertTrue(icebox.fileExists("MyNewLib"))
        XCTAssertTrue(icebox.fileExists("MyNewLib/Package.swift"))
    }
    
    func testExec() {
        let icebox = IceBox(template: .empty)
        
        let result = icebox.run("new", "MyNewExec", "--exec")
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

        Run: cd MyNewExec && ice build
        
        
        """)
        XCTAssertTrue(icebox.fileExists("MyNewExec"))
        XCTAssertTrue(icebox.fileExists("MyNewExec/Package.swift"))
    }
    
}
