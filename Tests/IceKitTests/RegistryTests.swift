//
//  RegistryTests.swift
//  IceKitTests
//
//  Created by Jake Heiser on 9/22/17.
//

import XCTest
import FileKit
import Regex
@testable import IceKit

class RegistryTests: XCTestCase {
    
    static var allTests = [
        ("testAutoRefresh", testAutoRefresh),
        ("testAdd", testAdd),
        ("testGet", testGet),
        ("testRemove", testRemove),
    ]
    
    lazy var registryPath = Path("Registry")
    lazy var sharedPath = registryPath + "shared/Registry"
    lazy var localPath = registryPath + "local.json"
    
    override func setUp() {
        try! registryPath.createDirectory(withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        try! registryPath.deleteFile()
    }
    
    func testAutoRefresh() throws {
        XCTAssertFalse(sharedPath.exists)
        _ = Registry(registryPath: registryPath)
        XCTAssertTrue(sharedPath.exists)
        XCTAssertTrue((sharedPath + "A.json").exists)
    }
    
    func testAdd() throws {
        let registry = Registry(registryPath: registryPath)
        try registry.add(name: "Ice-fake", url: "https://github.com/jakeheis/Ice-fake")
        
        let json = try JSONSerialization.jsonObject(with: try Data.read(from: localPath), options: []) as! [String: Any]
        let entries = json["entries"] as! [[String: Any]]
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries[0]["name"] as? String, "Ice-fake")
        XCTAssertEqual(entries[0]["url"] as? String, "https://github.com/jakeheis/Ice-fake")
        XCTAssertNotNil(json["lastRefreshed"])
    }
    
    func testGet() throws {
        try """
        {
          "entries": [
            {
              "name": "SwiftCLI-fake",
              "url": "https://github.com/jakeheis/SwiftCLI-fake"
            }
          ]
        }
        """.write(to: localPath)
        let registry = Registry(registryPath: registryPath)
        
        let entry = registry.get("SwiftCLI-fake")
        XCTAssertEqual(entry?.name, "SwiftCLI-fake")
        XCTAssertEqual(entry?.url, "https://github.com/jakeheis/SwiftCLI-fake")
        XCTAssertNil(entry?.description)
    }
    
    func testRemove() throws {
        try """
        {
          "entries": [
            {
              "name": "SwiftCLI-fake",
              "url": "https://github.com/jakeheis/SwiftCLI-fake"
            }
          ]
        }
        """.write(to: localPath)
        let registry = Registry(registryPath: registryPath)
        
        try registry.remove("SwiftCLI-fake")
        
        let json = try JSONSerialization.jsonObject(with: try Data.read(from: localPath), options: []) as! [String: Any]
        let entries = json["entries"] as! [[String: Any]]
        XCTAssertEqual(entries.count, 0)
        XCTAssertNotNil(json["lastRefreshed"])
        
        let entry = registry.get("SwiftCLI-fake")
        XCTAssertNil(entry)
    }
    
}
