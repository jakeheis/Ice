//
//  GlobalTests.swift
//  CoreTests
//
//  Created by Jake Heiser on 9/22/17.
//

import XCTest
import FileKit
@testable import Core

class GlobalTests: XCTestCase {
    
    let sandbox = Path("sandbox")
    lazy var packagesPath = sandbox + "Packages"
    lazy var configPath = sandbox + "config.json"
    
    override func setUp() {
        try! packagesPath.createDirectory(withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        try! sandbox.deleteFile()
    }
    
    func testAddRemove() throws {
        try! """
        {"bin" : "./sandbox/my/bin"}
        """.write(to: configPath)
        let config = Config(globalConfigPath: configPath)
        let global = Global(packagesPath: packagesPath, config: config)
        let ref = RepositoryReference("jakeheis/IceGlobalTest")!
        try global.add(ref: ref, version: nil)
        
        XCTAssertTrue((packagesPath + "IceGlobalTest").exists)
        XCTAssertTrue((packagesPath + "IceGlobalTest/.build/release").exists)
        XCTAssertTrue((sandbox + "my/bin/igt").exists)
        
        try global.remove(name: "IceGlobalTest")
        
        XCTAssertFalse((packagesPath + "IceGlobalTest").exists)
        XCTAssertFalse((sandbox + "my/bin/igt").exists)
    }
    
}
