//
//  RunTests.swift
//  CLITests
//
//  Created by Jake Heiser on 9/14/17.
//

import TestingUtilities
import XCTest

class RunTests: XCTestCase {
    
    func testBasicRun() {
        let icebox = IceBox(template: .exec)
        
        icebox.run("build")

        let result = icebox.run("run")
        IceAssertEqual(result.exitStatus, 0)
        IceAssertEqual(result.stderr, "")
        IceAssertEqual(result.stdout, """
        Hello, world!
        
        """)
    }
    
    func testWatchRun() {
        let icebox = IceBox(template: .exec)
                
        Differentiate.byPlatform(mac: {
            #if os(macOS)
            icebox.run("build")
            
            DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
                icebox.createFile(path: "Sources/Exec/main.swift", contents: "print(\"hey world\")\n")
            }
            
            DispatchQueue.global().asyncAfter(deadline: .now() + 10) {
                icebox.interrupt()
            }
            
            let result = icebox.run("run", "-w")
            IceAssertEqual(result.exitStatus, 2)
            IceAssertEqual(result.stderr, "")
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
            #endif
        }, linux: {
            let result = icebox.run("run", "-w")
            IceAssertEqual(result.exitStatus, 1)
            IceAssertEqual(result.stdout, "")
            IceAssertEqual(result.stderr, """
            
            Error: -w is not supported on Linux
            
            
            """)
        })
    }
    
}
