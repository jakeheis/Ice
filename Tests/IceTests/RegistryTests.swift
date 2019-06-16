//
//  RegistryTests.swift
//  CLITests
//
//  Created by Jake Heiser on 9/13/17.
//

import PathKit
import TestingUtilities
import XCTest

class RegistryTests: XCTestCase {
    
    func testAdd() throws {
        let icebox = IceBox(template: .empty)
        XCTAssertFalse(icebox.fileExists("global/Registry/local.json"))
        
        let result = icebox.run("registry", "add", "jakeheis/dne", "dne")
        IceAssertEqual(result.exitStatus, 0)
        IceAssertEqual(result.stderr, "")
        IceAssertEqual(result.stdout, "")
        
        XCTAssertTrue(icebox.fileExists("global/Registry/local.json"))
        let json = try JSONSerialization.jsonObject(with: icebox.fileContents("global/Registry/local.json")!, options: []) as! [String: Any]
        let entries = json["entries"] as! [[String: Any]]
        IceAssertEqual(entries.count, 1)
        IceAssertEqual(entries[0]["name"] as? String, "dne")
        IceAssertEqual(entries[0]["url"] as? String, "https://github.com/jakeheis/dne")
    }
    
    func testSharedLookup() {
        let result = IceBox(template: .empty).run("registry", "lookup", "Alamofire")
        IceAssertEqual(result.exitStatus, 0)
        IceAssertEqual(result.stderr, "")
        IceAssertEqual(result.stdout, """
        https://github.com/Alamofire/Alamofire
        
        """)
    }
    
    func testLocalLookup() {
        let icebox = IceBox(template: .empty)
        icebox.createFile(path: "global/Registry/local.json", contents: "{\"entries\":[{\"name\":\"dne\",\"url\":\"https:\\/\\/github.com\\/jakeheis\\/dne\"}]}")
        
        let result = icebox.run("registry", "lookup", "dne")
        IceAssertEqual(result.exitStatus, 0)
        IceAssertEqual(result.stderr, "")
        IceAssertEqual(result.stdout, """
        https://github.com/jakeheis/dne
        
        """)
    }
    
    func testRemove() {
        let icebox = IceBox(template: .empty)
        icebox.createFile(path: "global/Registry/local.json", contents: "{\"entries\":[{\"name\":\"dne\",\"url\":\"https:\\/\\/github.com\\/jakeheis\\/dne\"}]}")
        
        let result = icebox.run("registry", "remove", "dne")
        IceAssertEqual(result.exitStatus, 0)
        IceAssertEqual(result.stderr, "")
        IceAssertEqual(result.stdout, "")
        
        let json = try! JSONSerialization.jsonObject(with: icebox.fileContents("global/Registry/local.json")!, options: []) as! [String: Any]
        let entries = json["entries"] as! [[String: Any]]
        IceAssertEqual(entries.count, 0)
    }
    
}
