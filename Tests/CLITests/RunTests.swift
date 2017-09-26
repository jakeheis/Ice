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
        Runner.execute(args: ["build"], sandbox: .exec)

        let result = Runner.execute(args: ["run"], clean: false)
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        XCTAssertEqual(result.stdout, """
        Hello, world!
        
        """)
    }
    
    func testWatchRun() {
        Runner.execute(args: ["build"], sandbox: .exec)
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 4) {
            writeToSandbox(path: "Sources/Exec/main.swift", contents: "\nprint(\"hey world\")\n")
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 8) {
            Runner.interrupt()
        }
        
        let result = Runner.execute(args: ["run", "-w"], clean: false)
        XCTAssertEqual(result.exitStatus, 2)
        XCTAssertEqual(result.stderr, "")
        
        result.stdout.assert { (v) in
            v.equals("[ice] restarting due to changes...")
            v.equals("Hello, world!")
            v.equals("[ice] restarting due to changes...")
            v.equals("Compile Exec (1 sources)")
            v.matches("^Link ./.build/.*/debug/Exec$")
            v.equals("hey world")
            v.empty()
            v.done()
        }
    }
    
}
