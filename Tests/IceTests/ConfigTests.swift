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
        let reformatResult = Runner.execute(args: ["config", "get", "reformat"])
        XCTAssertEqual(reformatResult.exitStatus, 0)
        XCTAssertEqual(reformatResult.stderr, "")
        XCTAssertEqual(reformatResult.stdout, """
        false

        """)
        
        let globalResult = Runner.execute(args: ["config", "get", "reformat"], sandboxSetup: {
            writeToSandbox(path: "global/config.json", contents: "{\n  \"reformat\" : true\n}")
        })
        XCTAssertEqual(globalResult.exitStatus, 0)
        XCTAssertEqual(globalResult.stderr, "")
        XCTAssertEqual(globalResult.stdout, """
        true

        """)
    }
    
    func testSet() {
        let reformatResult = Runner.execute(args: ["config", "set", "reformat", "true"])
        XCTAssertEqual(reformatResult.exitStatus, 0)
        XCTAssertEqual(reformatResult.stderr, "")
        XCTAssertEqual(reformatResult.stdout, "")
        
        XCTAssertEqual(
            sandboxedFileContents("global/config.json"),
            "{\n  \"reformat\" : true\n}"
        )
    }
    
    func testSetInvalid() {
        let binResult = Runner.execute(args: ["config", "set", "email", "hi@hi.com"])
        XCTAssertEqual(binResult.exitStatus, 1)
        XCTAssertEqual(binResult.stderr, """
        
        Error: unrecognized config key

        Valid keys:
        
          reformat      whether Ice should organize your Package.swift (alphabetize, etc.); defaults to false

        
        """)
        XCTAssertEqual(binResult.stdout, "")
    }
    
    func testList() {
        let result = Runner.execute(args: ["config", "list"])
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        XCTAssertEqual(result.stdout, """
        {
          "reformat" : false
        }
        
        """)
    }
    
}
