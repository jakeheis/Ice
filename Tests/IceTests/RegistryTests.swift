//
//  RegistryTests.swift
//  CLITests
//
//  Created by Jake Heiser on 9/13/17.
//

import PathKit
import XCTest

class RegistryTests: XCTestCase {
    
    static var allTests = [
        ("testAdd", testAdd),
        ("testSharedLookup", testSharedLookup),
        ("testLocalLookup", testLocalLookup),
        ("testRemove", testRemove),
    ]
    
    func testAdd() {
        let icebox = IceBox(template: .empty)
        XCTAssertFalse(icebox.fileExists("global/Registry/local.json"))
        
        let result = icebox.run("registry", "add", "jakeheis/dne", "dne")
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        XCTAssertEqual(result.stdout, "")
        
        let json = try! JSONSerialization.jsonObject(with: icebox.fileContents("global/Registry/local.json")!, options: []) as! [String: Any]
        let entries = json["entries"] as! [[String: Any]]
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries[0]["name"] as? String, "dne")
        XCTAssertEqual(entries[0]["url"] as? String, "https://github.com/jakeheis/dne")
    }
    
    func testSharedLookup() {
        let result = IceBox(template: .empty).run("registry", "lookup", "Alamofire")
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        XCTAssertEqual(result.stdout, """
        https://github.com/Alamofire/Alamofire
        
        """)
    }
    
    func testLocalLookup() {
        let icebox = IceBox(template: .empty)
        icebox.createFile(path: "global/Registry/local.json", contents: "{\"entries\":[{\"name\":\"dne\",\"url\":\"https:\\/\\/github.com\\/jakeheis\\/dne\"}]}")
        
        let result = icebox.run("registry", "lookup", "dne")
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        XCTAssertEqual(result.stdout, """
        https://github.com/jakeheis/dne
        
        """)
    }
    
    func testRemove() {
        let icebox = IceBox(template: .empty)
        icebox.createFile(path: "global/Registry/local.json", contents: "{\"entries\":[{\"name\":\"dne\",\"url\":\"https:\\/\\/github.com\\/jakeheis\\/dne\"}]}")
        
        let result = icebox.run("registry", "remove", "dne")
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        XCTAssertEqual(result.stdout, "")
        
        let json = try! JSONSerialization.jsonObject(with: icebox.fileContents("global/Registry/local.json")!, options: []) as! [String: Any]
        let entries = json["entries"] as! [[String: Any]]
        XCTAssertEqual(entries.count, 0)
    }
    
}
