//
//  GlobalTests.swift
//  CLITests
//
//  Created by Jake Heiser on 9/14/17.
//

import XCTest
import Foundation

class GlobalTests: XCTestCase {
    
    func testAddRemove() {
        let result = Runner.execute(args: ["global", "add", "jakeheis/IceGlobalTest"])
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, """
        Cloning into 'global/Packages/IceGlobalTest'...
        
        """)
        
        print(result.stdout)
        let lines = result.stdout.components(separatedBy: "\n")
        XCTAssertEqual(lines.count, 3)
        XCTAssertEqual(lines[0], "Compile IceGlobalTest (1 sources)")
        XCTAssertMatch(lines[1], "^Link ./.build/.*/release/igt$")
        XCTAssertEqual(lines[2], "")
        
        XCTAssertTrue(sandboxFileExists(path: "global/Packages"))
        XCTAssertTrue(sandboxFileExists(path: "global/Packages/IceGlobalTest"))
        XCTAssertTrue(sandboxFileExists(path: "global/Packages/IceGlobalTest/.build"))
        XCTAssertTrue(sandboxFileExists(path: "global/bin"))
        XCTAssertTrue(sandboxFileExists(path: "global/bin/igt"))
        XCTAssertFalse(sandboxFileExists(path: "global/bin/ModuleCache"))
        XCTAssertMatch(readSandboxLink(path: "global/bin/igt"), ".build/.*/release/igt$")
        
        let removeResult = Runner.execute(args: ["global", "remove", "IceGlobalTest"], clean: false)
        XCTAssertEqual(removeResult.exitStatus, 0)
        XCTAssertEqual(removeResult.stderr, """
        """)
        XCTAssertEqual(removeResult.stdout, """
        Unlinking: global/bin/igt
        
        """)
        XCTAssertFalse(sandboxFileExists(path: "global/Packages/IceGlobalTest"))
        XCTAssertFalse(sandboxFileExists(path: "global/bin/igt"))
    }
    
}
