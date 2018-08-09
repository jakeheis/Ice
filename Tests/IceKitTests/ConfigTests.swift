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
        
        let config = Config(globalPath: globalPath, localDirectory: directory)
        XCTAssertEqual(config.get(\.reformat), true)
        XCTAssertEqual(config.get(.reformat), "true")
        
        try! localPath.write("""
        {
          "reformat" : false
        }
        """)
        
        let config2 = Config(globalPath: globalPath, localDirectory: directory)
        XCTAssertEqual(config2.get(\.reformat), false)
        XCTAssertEqual(config2.get(.reformat), "false")
    }
    
    func testSet() {
        try! globalPath.write("""
        {
          "reformat" : true
        }
        """)

        let config = Config(globalPath: globalPath, localDirectory: directory)
        XCTAssertEqual(config.get(\.reformat), true)
        
        try! config.set(\.reformat, value: false, global: true)
        
        let object = try! JSONSerialization.jsonObject(with: globalPath.read(), options: []) as! [String: Bool]
        XCTAssertEqual(object["reformat"], false)
        XCTAssertEqual(config.get(\.reformat), false)
        
        try! config.set(\.reformat, value: true, global: false)
        
        let object2 = try! JSONSerialization.jsonObject(with: localPath.read(), options: []) as! [String: Bool]
        XCTAssertEqual(object2["reformat"], true)
        XCTAssertEqual(config.get(\.reformat), true)
    }
    
}
