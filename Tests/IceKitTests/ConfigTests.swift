//
//  ConfigTests.swift
//  IceKitTests
//
//  Created by Jake Heiser on 9/20/17.
//

import XCTest
import PathKit
@testable import IceKit

class ConfigTests: XCTestCase {
    
    static var allTests = [
        ("testGet", testGet),
        ("testSet", testSet),
    ]
    
    let directory = Path("/tmp/ice_config")
    var globalPath: Path {  return directory + "config.json" }
    var localPath: Path {  return directory + "ice.json" }
    
    override func setUp() {
        if directory.exists {
            try! directory.delete()
        }
        try! directory.mkpath()
    }
    
    func testGet() {
        try! globalPath.write("""
        {
          "reformat" : true
        }
        """)
        
        let config = ConfigManager(global: directory, local: directory)
        XCTAssertEqual(config.local.reformat, nil)
        XCTAssertEqual(config.global.reformat, true)
        XCTAssertEqual(config.resolved.reformat, true)
        
        try! localPath.write("""
        {
          "reformat" : false
        }
        """)
        
        let config2 = ConfigManager(global: directory, local: directory)
        XCTAssertEqual(config2.local.reformat, false)
        XCTAssertEqual(config2.global.reformat, true)
        XCTAssertEqual(config2.resolved.reformat, false)
    }
    
    func testSet() throws {
        try! globalPath.write("""
        {
          "reformat" : true
        }
        """)

        let config = ConfigManager(global: directory, local: directory)
        XCTAssertEqual(config.resolved.reformat, true)
        
        try config.update(scope: .global) { $0.reformat = false }
        
        let object = try! JSONSerialization.jsonObject(with: globalPath.read(), options: []) as! [String: Bool]
        XCTAssertEqual(object["reformat"], false)
        
        XCTAssertEqual(config.local.reformat, nil)
        XCTAssertEqual(config.global.reformat, false)
        XCTAssertEqual(config.resolved.reformat, false)
        
        try config.update(scope: .local) { $0.reformat = true }
        
        let object2 = try! JSONSerialization.jsonObject(with: localPath.read(), options: []) as! [String: Bool]
        XCTAssertEqual(object2["reformat"], true)
        
        XCTAssertEqual(config.local.reformat, true)
        XCTAssertEqual(config.global.reformat, false)
        XCTAssertEqual(config.resolved.reformat, true)
    }
    
}
