//
//  BuildTests.swift
//  CLITests
//
//  Created by Jake Heiser on 9/14/17.
//

import XCTest

class BuildTests: XCTestCase {
    
    static var allTests = [
        ("testSimpleBuild", testSimpleBuild),
        ("testCleanBuild", testCleanBuild),
        ("testReleaseBuild", testReleaseBuild),
        ("testWatchBuild", testWatchBuild),
        ("testBuildErrors", testBuildErrors),
        ("testBuildTarget", testBuildTarget),
        ("testBuildProduct", testBuildProduct),
    ]
    
    func testSimpleBuild() {
        let icebox = IceBox(template: .exec)
        let result = icebox.run("build")
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        
        result.assertStdout { (v) in
            v.equals("Fetch https://github.com/jakeheis/SwiftCLI")
            v.equals("Clone https://github.com/jakeheis/SwiftCLI")
            v.equals("Resolve https://github.com/jakeheis/SwiftCLI at 4.1.2")
            v.equals("Compile SwiftCLI (23 sources)")
            v.equals("Compile Exec (1 sources)")
            v.matches("^Link \\./\\.build/.*/debug/Exec$")
            v.empty()
            v.done()
        }
        
        XCTAssertTrue(icebox.fileExists(".build/debug/Exec"))
    }
    
    func testCleanBuild() {
        let icebox = IceBox(template: .lib)
        
        let initial = icebox.run("build", "-c")
        XCTAssertEqual(initial.exitStatus, 0)
        XCTAssertEqual(initial.stderr, "")
        XCTAssertEqual(initial.stdout, """
        Compile Lib (1 sources)

        """)
        
        let followup = icebox.run("build", "-c")
        XCTAssertEqual(followup.exitStatus, 0)
        XCTAssertEqual(followup.stderr, "")
        XCTAssertEqual(followup.stdout, """
        Compile Lib (1 sources)

        """)
        
        XCTAssertTrue(icebox.fileExists(".build/debug"))
    }
    
    func testReleaseBuild() {
        let icebox = IceBox(template: .lib)
        
        let initial = icebox.run("build", "-r")
        XCTAssertEqual(initial.exitStatus, 0)
        XCTAssertEqual(initial.stderr, "")
        
        XCTAssertEqual(initial.stdout, """
        Compile Lib (1 sources)

        """)
        
        XCTAssertTrue(icebox.fileExists(".build/release"))
        XCTAssertFalse(icebox.fileExists(".build/debug"))
    }
    
    func testWatchBuild() {
        let icebox = IceBox(template: .lib)
        
        #if !os(Linux) && !os(Android)
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 4) {
            icebox.createFile(path: "Sources/Lib/Lib.swift", contents: "\nprint(\"hey world\")\n")
        }

        DispatchQueue.global().asyncAfter(deadline: .now() + 6) {
            icebox.interrupt()
        }
        
        let result = icebox.run("build", "-w")
        
        XCTAssertEqual(result.exitStatus, 2)
        XCTAssertEqual(result.stderr, "")
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
        
        #else
        
        let result = icebox.run("build", "-w")
        XCTAssertEqual(result.exitStatus, 1)
        XCTAssertEqual(result.stdout, "")
        XCTAssertEqual(result.stderr, """

        Error: -w is not supported on Linux


        """)
        
        #endif
    }
    
    func testBuildErrors() {
        let icebox = IceBox(template: .exec)
        
        let contents = """
        let str: String? = "text"
        print(str)

        let int: Int = "hello world"

        """
        icebox.createFile(path: "Sources/Exec/main.swift", contents: contents)
        
        let result = icebox.run("build")
        XCTAssertEqual(result.exitStatus, 1)
        XCTAssertEqual(result.stderr, "")
        XCTAssertEqual(result.stdout, """
        Fetch https://github.com/jakeheis/SwiftCLI
        Clone https://github.com/jakeheis/SwiftCLI
        Resolve https://github.com/jakeheis/SwiftCLI at 4.1.2
        Compile SwiftCLI (23 sources)
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
    
    func testBuildTarget() {
        let success = IceBox(template: .lib).run("build", "--target=Lib")
        XCTAssertEqual(success.exitStatus, 0)
        XCTAssertEqual(success.stderr, "")
        XCTAssertEqual(success.stdout, """
        Compile Lib (1 sources)

        """)
        
        let error = IceBox(template: .lib).run("build", "--target=Library")
        XCTAssertEqual(error.exitStatus, 1)
        XCTAssertEqual(error.stdout, "")
        XCTAssertEqual(error.stderr, """
        
        Error: no target named 'Library'

        
        """)
    }
    
    func testBuildProduct() {
        let result = IceBox(template: .exec).run("build", "--product=Exec")
        XCTAssertEqual(result.exitStatus, 0)
        XCTAssertEqual(result.stderr, "")
        result.assertStdout { (v) in
            v.equals("Fetch https://github.com/jakeheis/SwiftCLI")
            v.equals("Clone https://github.com/jakeheis/SwiftCLI")
            v.equals("Resolve https://github.com/jakeheis/SwiftCLI at 4.1.2")
            v.equals("Compile SwiftCLI (23 sources)")
            v.equals("Compile Exec (1 sources)")
            v.matches("^Link \\./\\.build/.*/debug/Exec$")
            v.empty()
            v.done()
        }
        
        let result2 = IceBox(template: .exec).run("build", "--product=Prod")
        XCTAssertEqual(result2.exitStatus, 1)
        XCTAssertEqual(result2.stdout, """
        Fetch https://github.com/jakeheis/SwiftCLI
        Clone https://github.com/jakeheis/SwiftCLI
        Resolve https://github.com/jakeheis/SwiftCLI at 4.1.2
        
        """)
        XCTAssertEqual(result2.stderr, """
        
        Error: no product named 'Prod'

        
        """)
    }
    
}
