//
//  BuildTests.swift
//  CLITests
//
//  Created by Jake Heiser on 9/14/17.
//

import XCTest

class BuildTests: XCTestCase {
    
    func testSimpleBuild() {
        let result = Runner.execute(args: ["build"], sandbox: .exec)
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        
        result.stdout.assert { (v) in
            v.equals("Fetch https://github.com/jakeheis/SwiftCLI")
            v.equals("Compile SwiftCLI (21 sources)")
            v.equals("Compile Exec (1 sources)")
            v.matches("^Link ./.build/.*0/debug/Exec$")
            v.empty()
            v.done()
        }
        
        XCTAssertTrue(sandboxFileExists(path: ".build/debug/Exec"))
    }
    
    func testCleanBuild() {
        let initial = Runner.execute(args: ["build", "-c"], sandbox: .lib)
        XCTAssertEqual(initial.exitStatus, 0)
        XCTAssertEqual(initial.stderr, "")
        
        XCTAssertEqual(initial.stdout, """
        Compile Lib (1 sources)

        """)
        
        let followup = Runner.execute(args: ["build", "-c"], clean: false)
        XCTAssertEqual(followup.exitStatus, 0)
        XCTAssertEqual(followup.stderr, "")
        
        XCTAssertEqual(followup.stdout, """
        Compile Lib (1 sources)

        """)
        
        XCTAssertTrue(sandboxFileExists(path: ".build/debug"))
    }
    
    func testReleaseBuild() {
        let initial = Runner.execute(args: ["build", "-r"], sandbox: .lib)
        XCTAssertEqual(initial.exitStatus, 0)
        XCTAssertEqual(initial.stderr, "")
        
        XCTAssertEqual(initial.stdout, """
        Compile Lib (1 sources)

        """)
        
        XCTAssertTrue(sandboxFileExists(path: ".build/release"))
        XCTAssertFalse(sandboxFileExists(path: ".build/debug"))
    }
    
    func testWatchBuild() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
            writeToSandbox(path: "Sources/Lib/Lib.swift", contents: "\nprint(\"hey world\")\n")
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 6) {
            Runner.interrupt()
        }
        
        let result = Runner.execute(args: ["build", "-w"], sandbox: .lib)
        XCTAssertEqual(result.exitStatus, 2)
        result.stderr.assert { (v) in
            v.empty()
            v.matches("^Error: terminated\\(1\\):")
            v.empty()
            v.done()
        }
        XCTAssertEqual(result.stdout, """
        [ice] rebuilding due to changes...
        Compile Lib (1 sources)
        [ice] rebuilding due to changes...
        Compile Lib (1 sources)
        
          ● Error: expressions are not allowed at the top level

            print("hey world")
            ^
            at Sources/Lib/Lib.swift:2
        
        
        """)
    }
    
    func testBuildErrors() {
        let file = """
        let str: String? = "text"
        print(str)

        let int: Int = "hello world"

        """
        let result = Runner.execute(args: ["build"], sandbox: .exec, sandboxSetup: {
            writeToSandbox(path: "Sources/Exec/main.swift", contents: file)
        })
        
        XCTAssertEqual(result.exitStatus, 1)
        result.stderr.assert { (v) in
            v.empty()
            v.matches("^Error: terminated\\(1\\):")
            v.empty()
            v.done()
        }
        XCTAssertEqual(result.stdout, """
        Fetch https://github.com/jakeheis/SwiftCLI
        Compile SwiftCLI (21 sources)
        Compile Exec (1 sources)

          ● Warning: expression implicitly coerced from 'String?' to Any

            print(str)
                  ^^^
            at Sources/Exec/main.swift:2

            Note: provide a default value to avoid this warning

            print(str)
                  ^^^
                      ?? <#default value#>

            at Sources/Exec/main.swift:2

            Note: force-unwrap the value to avoid this warning

            print(str)
                  ^^^
                     !

            at Sources/Exec/main.swift:2

            Note: explicitly cast to Any with 'as Any' to silence this warning

            print(str)
                  ^^^
                      as Any

            at Sources/Exec/main.swift:2


          ● Error: cannot convert value of type 'String' to specified type 'Int'

            let int: Int = "hello world"
                           ^^^^^^^^^^^^^
            at Sources/Exec/main.swift:4
        
        
        """)
    }
    
}
