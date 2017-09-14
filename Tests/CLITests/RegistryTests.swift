//
//  RegistryTests.swift
//  CLITests
//
//  Created by Jake Heiser on 9/13/17.
//

import XCTest


class RegistryTests: XCTestCase {
    
    func testAdd() {
        XCTAssertEqual(sandboxedFileContents("global/Registry/local.json"), nil)
        
        let result = Runner.execute(args: ["registry", "add", "jakeheis/dne", "dne"])
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        XCTAssertEqual(result.stdout, "")
        
        XCTAssertEqual(
            sandboxedFileContents("global/Registry/local.json"),
            "{\"entries\":[{\"name\":\"dne\",\"url\":\"https:\\/\\/github.com\\/jakeheis\\/dne\"}]}"
        )
    }
    
    func testSharedLookup() {
        let result = Runner.execute(args: ["registry", "lookup", "Alamofire"])
        
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        XCTAssertEqual(result.stdout, """
        https://github.com/Alamofire/Alamofire
        
        """)
    }
    
    func testLocalLookup() {
        let result = Runner.execute(args: ["registry", "lookup", "dne"], sandboxSetup: {
            writeToSandbox(
                path: "global/Registry/local.json",
                contents: "{\"entries\":[{\"name\":\"dne\",\"url\":\"https:\\/\\/github.com\\/jakeheis\\/dne\"}]}"
            )
        })
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        XCTAssertEqual(result.stdout, """
        https://github.com/jakeheis/dne
        
        """)
    }
    
    func testRemove() {
        let result = Runner.execute(args: ["registry", "remove", "dne"], sandboxSetup: {
            writeToSandbox(
                path: "global/Registry/local.json",
                contents: "{\"entries\":[{\"name\":\"dne\",\"url\":\"https:\\/\\/github.com\\/jakeheis\\/dne\"}]}"
            )
        })
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        XCTAssertEqual(result.stdout, "")
        
        XCTAssertEqual(sandboxedFileContents("global/Registry/local.json"), "{\"entries\":[]}")
    }
    
}
