//
//  ConfigTests.swift
//  CoreTests
//
//  Created by Jake Heiser on 9/20/17.
//

import XCTest
import FileKit
@testable import Core

class ConfigTests: XCTestCase {
    
    let root = Path(".sandboxed_config")
    lazy var configPath = root + "config.json"

    override func setUp() {
        try! root.createDirectory(withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        try! root.deleteFile()
    }
    
    func testGet() {
        try! """
        {
          "bin" : "/.icebox/bin",
          "strict" : true
        }
        """.write(to: configPath)
        
        let config = Config(globalRoot: root)
        XCTAssertEqual(config.get(\.bin), "/.icebox/bin")
        XCTAssertEqual(config.get(\.strict), true)
    }
    
    func testSet() {
        try! """
        {
          "bin" : "/.icebox/bin",
          "strict" : true
        }
        """.write(to: configPath)

        let config = Config(globalRoot: root)
        try! config.set(\.bin, value: "/my/special/bin")

        
        XCTAssertEqual(try? String.read(from: configPath), """
        {
          "bin" : "\\/my\\/special\\/bin",
          "strict" : true
        }
        """)
        XCTAssertEqual(config.get(\.bin), "/my/special/bin")
        XCTAssertEqual(config.get(\.strict), true)
    }
    
    func testLayer() {
        let top = ConfigFile(
            bin: "/my/bin",
            strict: nil
        )
        let bottom = ConfigFile(
            bin: "/.icebox/bin",
            strict: false
        )
        
        let result = ConfigFile.layer(config: top, onto: bottom)
        XCTAssertEqual(result.bin, "/my/bin")
        XCTAssertEqual(result.strict, false)
    }
    
}
