//
//  ConfigTests.swift
//  CLITests
//
//  Created by Jake Heiser on 9/13/17.
//

import XCTest

class ConfigTests: XCTestCase {
    
    static var allTests = [
        ("testGet", testGet),
        ("testSet", testSet),
        ("testSetInvalid", testSetInvalid),
        ("testList", testList),
    ]
    
    func testGet() {
        let reformatResult = IceBox(template: .empty).run("config", "get", "reformat")
        XCTAssertEqual(reformatResult.exitStatus, 0)
        XCTAssertEqual(reformatResult.stderr, "")
        XCTAssertEqual(reformatResult.stdout, """
        false

        """)
        
        let icebox = IceBox(template: .empty)
        icebox.createFile(path: "global/config.json", contents: "{\n  \"reformat\" : true\n}")
        let globalResult = icebox.run("config", "get", "reformat")
        XCTAssertEqual(globalResult.exitStatus, 0)
        XCTAssertEqual(globalResult.stderr, "")
        XCTAssertEqual(globalResult.stdout, """
        true

        """)
    }
    
    func testSet() {
        let icebox = IceBox(template: .empty)
        
        let reformatResult = icebox.run("config", "set", "reformat", "true")
        XCTAssertEqual(reformatResult.exitStatus, 0)
        XCTAssertEqual(reformatResult.stderr, "")
        XCTAssertEqual(reformatResult.stdout, "")
        
        XCTAssertEqual(icebox.fileContents("global/config.json"), "{\n  \"reformat\" : true\n}")
    }
    
    func testSetInvalid() {
        let result = IceBox(template: .empty).run("config", "set", "email", "hi@hi.com")
        XCTAssertEqual(result.exitStatus, 1)
        XCTAssertEqual(result.stdout, "")
        XCTAssertEqual(result.stderr, """
        
        Error: unrecognized config key

        Valid keys:
        
          reformat      whether Ice should organize your Package.swift (alphabetize, etc.); defaults to false

        
        """)
    }
    
    func testList() {
        let result = IceBox(template: .empty).run("config", "list")
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        XCTAssertEqual(result.stdout, """
        {
          "reformat" : false
        }
        
        """)
    }
    
}
