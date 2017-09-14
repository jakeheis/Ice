//
//  NewTests.swift
//  CLITests
//
//  Created by Jake Heiser on 9/13/17.
//

import XCTest

class NewTests: XCTestCase {
    
    func testLib() {
        let result = Runner.execute(args: ["new", "MyNewLib", "--lib"])
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

        Run: cd MyNewLib && ice build
        
        
        """)
        
        XCTAssertTrue(sandboxFileExists(path: "MyNewLib"))
        XCTAssertTrue(sandboxFileExists(path: "MyNewLib/Package.swift"))
    }
    
    func testExec() {
        let result = Runner.execute(args: ["new", "MyNewExec", "--exec"])
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
        XCTAssertTrue(sandboxFileExists(path: "MyNewExec"))
        XCTAssertTrue(sandboxFileExists(path: "MyNewExec/Package.swift"))
    }
    
}
