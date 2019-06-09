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
        IceAssertEqual(config.local.reformat, nil)
        IceAssertEqual(config.global.reformat, true)
        IceAssertEqual(config.resolved.reformat, true)
        
        try! localPath.write("""
        {
          "reformat" : false
        }
        """)
        
        let config2 = ConfigManager(global: directory, local: directory)
        IceAssertEqual(config2.local.reformat, false)
        IceAssertEqual(config2.global.reformat, true)
        IceAssertEqual(config2.resolved.reformat, false)
    }
    
    func testSet() throws {
        try! globalPath.write("""
        {
          "reformat" : true
        }
        """)

        let config = ConfigManager(global: directory, local: directory)
        IceAssertEqual(config.resolved.reformat, true)
        
        try config.update(scope: .global) { $0.reformat = false }
        
        let object = try! JSONSerialization.jsonObject(with: globalPath.read(), options: []) as! [String: Bool]
        IceAssertEqual(object["reformat"], false)
        
        IceAssertEqual(config.local.reformat, nil)
        IceAssertEqual(config.global.reformat, false)
        IceAssertEqual(config.resolved.reformat, false)
        
        try config.update(scope: .local) { $0.reformat = true }
        
        let object2 = try! JSONSerialization.jsonObject(with: localPath.read(), options: []) as! [String: Bool]
        IceAssertEqual(object2["reformat"], true)
        
        IceAssertEqual(config.local.reformat, true)
        IceAssertEqual(config.global.reformat, false)
        IceAssertEqual(config.resolved.reformat, true)
    }
    
}
