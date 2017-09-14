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
        
        let strictResult = Runner.execute(args: ["config", "get", "strict"])
        XCTAssertEqual(strictResult.exitStatus, 0)
        XCTAssertEqual(strictResult.stderr, "")
        XCTAssertEqual(strictResult.stdout, """
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
        
        let strictResult = Runner.execute(args: ["config", "set", "strict", "true"])
        XCTAssertEqual(strictResult.exitStatus, 0)
        XCTAssertEqual(strictResult.stderr, "")
        XCTAssertEqual(strictResult.stdout, "")
        
        XCTAssertEqual(
            sandboxedFileContents("global/config.json"),
            "{\n  \"strict\" : true\n}"
        )
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
          "strict" : false
        }
        
        """)
    }
    
}
