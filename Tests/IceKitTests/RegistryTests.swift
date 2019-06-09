//
//  RegistryTests.swift
//  IceKitTests
//
//  Created by Jake Heiser on 9/22/17.
//

@testable import IceKit
import PathKit
import TestingUtilities
import XCTest

class RegistryTests: XCTestCase {
    
    let sharedPath: Path = "shared" + "Registry"
    let localPath: Path  = "local.json"
    
    func testAutoClone() throws {
        IceBox(template: .empty).inside {
            XCTAssertFalse(sharedPath.exists)
            let registry = Registry(registryPath: .current)
            _ = registry.get("Alamofire")
            XCTAssertTrue(sharedPath.exists)
            XCTAssertTrue((sharedPath + "A.json").exists)
        }
    }
    
    func testAdd() throws {
        IceBox(template: .empty).inside {
            let registry = Registry(registryPath: .current)
            try registry.add(name: "Ice-fake", url: "https://github.com/jakeheis/Ice-fake")
            
            let json = try JSONSerialization.jsonObject(with: try localPath.read(), options: []) as! [String: Any]
            let entries = json["entries"] as! [[String: Any]]
            IceAssertEqual(entries.count, 1)
            IceAssertEqual(entries[0]["name"] as? String, "Ice-fake")
            IceAssertEqual(entries[0]["url"] as? String, "https://github.com/jakeheis/Ice-fake")
        }
    }
    
    func testGet() throws {
        IceBox(template: .empty).inside {
            try localPath.write("""
            {
              "entries": [
                {
                  "name": "SwiftCLI-fake",
                  "url": "https://github.com/jakeheis/SwiftCLI-fake"
                }
              ]
            }
            """)
            let registry = Registry(registryPath: .current)
            
            let entry = registry.get("SwiftCLI-fake")
            IceAssertEqual(entry?.name, "SwiftCLI-fake")
            IceAssertEqual(entry?.url, "https://github.com/jakeheis/SwiftCLI-fake")
            XCTAssertNil(entry?.description)
        }
    }
    
    func testRemove() throws {
        IceBox(template: .empty).inside {
            try localPath.write("""
            {
              "entries": [
                {
                  "name": "SwiftCLI-fake",
                  "url": "https://github.com/jakeheis/SwiftCLI-fake"
                }
              ]
            }
            """)
            let registry = Registry(registryPath: .current)
            
            let beforeEntry = registry.get("SwiftCLI-fake")
            XCTAssertNotNil(beforeEntry)
            
            try registry.remove("SwiftCLI-fake")
            
            let json = try JSONSerialization.jsonObject(with: try localPath.read(), options: []) as! [String: Any]
            let entries = json["entries"] as! [[String: Any]]
            IceAssertEqual(entries.count, 0)
            
            let afterEntry = registry.get("SwiftCLI-fake")
            XCTAssertNil(afterEntry)
        }
    }
    
}
