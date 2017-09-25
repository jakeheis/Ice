//
//  ConfigTests.swift
//  CLITests
//
//  Created by Jake Heiser on 9/13/17.
//

import XCTest

class ConfigTests: XCTestCase {
    
    func testGet() {
        let binResult = Runner.execute(args: ["config", "get", "bin"])
        XCTAssertEqual(binResult.exitStatus, 0)
        XCTAssertEqual(binResult.stderr, "")
        XCTAssertEqual(binResult.stdout, """
        global/bin

        """)
        
        let reformatResult = Runner.execute(args: ["config", "get", "reformat"])
        XCTAssertEqual(reformatResult.exitStatus, 0)
        XCTAssertEqual(reformatResult.stderr, "")
        XCTAssertEqual(reformatResult.stdout, """
        false

        """)
        
        let globalResult = Runner.execute(args: ["config", "get", "bin"], sandboxSetup: {
            writeToSandbox(path: "global/config.json", contents: "{\n  \"bin\" : \"localBin\"\n}")
        })
        XCTAssertEqual(globalResult.exitStatus, 0)
        XCTAssertEqual(globalResult.stderr, "")
        XCTAssertEqual(globalResult.stdout, """
        localBin

        """)
    }
    
    func testSet() {
        let binResult = Runner.execute(args: ["config", "set", "bin", "localBin"])
        XCTAssertEqual(binResult.exitStatus, 0)
        XCTAssertEqual(binResult.stderr, "")
        XCTAssertEqual(binResult.stdout, "")
        
        XCTAssertEqual(
            sandboxedFileContents("global/config.json"),
            "{\n  \"bin\" : \"localBin\"\n}"
        )
        
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
        
          bin           the directory to which Ice should symlink global executables; defaults to /usr/bin/local/bin
          reformat      whether Ice should organize your Package.swift (alphabetize, etc.); defaults to false

        
        """)
        XCTAssertEqual(binResult.stdout, "")
    }
    
    func testList() {
        let result = Runner.execute(args: ["config", "list"], sandboxSetup: {
            writeToSandbox(path: "global/config.json", contents: "{\n  \"bin\" : \"localBin\"\n}")
        })
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        XCTAssertEqual(result.stdout, """
        {
          "bin" : "localBin",
          "reformat" : false
        }
        
        """)
    }
    
}
