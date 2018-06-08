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
        ("testLayer", testLayer),
        ("testMigration", testMigration)
    ]
    
    let configPath = Path("config.json")
    
    override func tearDown() {
        if configPath.exists {
            try! configPath.delete()
        }
    }
    
    func testGet() {
        try! configPath.write("""
        {
          "reformat" : true
        }
        """)
        
        let config = Config(globalConfigPath: configPath)
        XCTAssertEqual(config.get(\.reformat), true)
    }
    
    func testSet() {
        try! configPath.write("""
        {
          "reformat" : true
        }
        """)

        let config = Config(globalConfigPath: configPath)
        try! config.set(\.reformat, value: false)

        
        XCTAssertEqual(try? configPath.read(), """
        {
          "reformat" : false
        }
        """)
        XCTAssertEqual(config.get(\.reformat), false)
    }
    
    func testLayer() {
        let top = ConfigFile(
            reformat: nil
        )
        let bottom = ConfigFile(
            reformat: false
        )
        
        let result = ConfigFile.layer(config: top, onto: bottom)
        XCTAssertEqual(result.reformat, false)
    }
    
    func testMigration() {
        try! configPath.write("""
        {
          "bin" : "/.icebox/bin",
          "reformat" : true
        }
        """)
        
        let config = Config(globalConfigPath: configPath)
        try! config.set(\.reformat, value: false)
        
        XCTAssertEqual(try? configPath.read(), """
        {
          "reformat" : false
        }
        """)
    }
    
}
