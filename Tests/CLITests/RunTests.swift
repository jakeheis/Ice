//
//  RunTests.swift
//  CLITests
//
//  Created by Jake Heiser on 9/14/17.
//

import XCTest

class RunTests: XCTestCase {
    
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
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
            writeToSandbox(path: "Sources/Exec/main.swift", contents: "\nprint(\"hey world\")\n")
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 6) {
            Runner.interrupt()
        }
        
        let result = Runner.execute(args: ["run", "-w"], clean: false)
        XCTAssertEqual(result.exitStatus, 2)
        XCTAssertEqual(result.stderr, "")
        
        let lines = result.stdout.components(separatedBy: "\n")
        XCTAssertEqual(lines.count, 7)
        XCTAssertEqual(lines[0..<4].joined(separator: "\n"), """
        [ice] restarting due to changes...
        Hello, world!
        [ice] restarting due to changes...
        Compile Exec (1 sources)
        """)
        XCTAssertMatch(lines[4], "^Link ./.build/.*/debug/Exec$")
        XCTAssertEqual(lines[5], "hey world")
        XCTAssertEqual(lines[6], "")
    }
    
}
