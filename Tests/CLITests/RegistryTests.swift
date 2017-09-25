//
//  RegistryTests.swift
//  CLITests
//
//  Created by Jake Heiser on 9/13/17.
//

import XCTest


class RegistryTests: XCTestCase {
    
    override func tearDown() {
        Runner.clean()
    }
    
    func testAdd() {
        XCTAssertNil(sandboxedFileContents("global/Registry/local.json"))
        
        let result = Runner.execute(args: ["registry", "add", "jakeheis/dne", "dne"])
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        XCTAssertEqual(result.stdout, "")
        
        let json = try! JSONSerialization.jsonObject(with: sandboxedFileData("global/Registry/local.json")!, options: []) as! [String: Any]
        let entries = json["entries"] as! [[String: Any]]
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries[0]["name"] as? String, "dne")
        XCTAssertEqual(entries[0]["url"] as? String, "https://github.com/jakeheis/dne")
        XCTAssertNotNil(json["lastRefreshed"])
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
        
        let json = try! JSONSerialization.jsonObject(with: sandboxedFileData("global/Registry/local.json")!, options: []) as! [String: Any]
        let entries = json["entries"] as! [[String: Any]]
        XCTAssertEqual(entries.count, 0)
        XCTAssertNotNil(json["lastRefreshed"])
    }
    
}
