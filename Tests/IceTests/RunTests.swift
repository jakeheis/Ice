//
//  RunTests.swift
//  CLITests
//
//  Created by Jake Heiser on 9/14/17.
//

import XCTest

class RunTests: XCTestCase {
    
    static var allTests = [
        ("testBasicRun", testBasicRun),
        ("testWatchRun", testWatchRun),
    ]
    
    func testBasicRun() {
        let icebox = IceBox(template: .exec)
        
        icebox.run("build")

        let result = icebox.run("run")
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        XCTAssertEqual(result.stdout, """
        Hello, world!
        
        """)
    }
    
    func testWatchRun() {
        let icebox = IceBox(template: .exec)
        
        #if !os(Linux) && !os(Android)
        
        icebox.run("build")
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
            icebox.createFile(path: "Sources/Exec/main.swift", contents: "print(\"hey world\")\n")
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 10) {
            icebox.interrupt()
        }
        
        let result = icebox.run("run", "-w")
        XCTAssertEqual(result.exitStatus, 2)
        XCTAssertEqual(result.stderr, "")
        result.assertStdout { (v) in
            v.equals("[ice] restarting due to changes...")
            v.equals("Hello, world!")
            v.equals("[ice] restarting due to changes...")
            v.equals("Compile Exec (1 sources)")
            v.matches("^Link ./.build/.*/debug/Exec$")
            v.equals("hey world")
            v.empty()
            v.done()
        }
        
        #else
        
        let result = icebox.run("run", "-w")
        XCTAssertEqual(result.exitStatus, 1)
        XCTAssertEqual(result.stdout, "")
        XCTAssertEqual(result.stderr, """
        
        Error: -w is not supported on Linux
        
        
        """)
        
        #endif
    }
    
}
