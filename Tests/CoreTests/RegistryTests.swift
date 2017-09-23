//
//  RegistryTests.swift
//  CoreTests
//
//  Created by Jake Heiser on 9/22/17.
//

import XCTest
import FileKit
@testable import Core

class RegistryTests: XCTestCase {
    
    lazy var registryPath = Path("Registry")
    lazy var sharedPath = registryPath + "shared/Registry"
    lazy var localPath = registryPath + "local.json"
    
    override func setUp() {
        try! registryPath.createDirectory(withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        try! registryPath.deleteFile()
    }
    
    func testRefresh() throws {
        let registry = Registry(registryPath: registryPath)
        XCTAssertFalse(sharedPath.exists)
        
        try registry.refresh()
        
        XCTAssertTrue(sharedPath.exists)
        XCTAssertTrue((sharedPath + "A.json").exists)
    }
    
    func testAdd() throws {
        let registry = Registry(registryPath: registryPath)
        try registry.add(name: "Ice-fake", url: "https://github.com/jakeheis/Ice-fake")
        
        XCTAssertEqual(try String.read(from: localPath), """
        {"entries":[{"name":"Ice-fake","url":"https:\\/\\/github.com\\/jakeheis\\/Ice-fake"}]}
        """)
    }
    
    func testGet() throws {
        let registry = Registry(registryPath: registryPath)
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
        
        let entry = registry.get("SwiftCLI-fake")
        XCTAssertEqual(entry?.name, "SwiftCLI-fake")
        XCTAssertEqual(entry?.url, "https://github.com/jakeheis/SwiftCLI-fake")
        XCTAssertNil(entry?.description)
    }
    
    func testRemove() throws {
        let registry = Registry(registryPath: registryPath)
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
        
        try registry.remove("SwiftCLI-fake")
        
        XCTAssertEqual(try String.read(from: localPath), """
        {"entries":[]}
        """)
        
        let entry = registry.get("SwiftCLI-fake")
        XCTAssertNil(entry)
    }
    
}
