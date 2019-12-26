//
//  BuildTests.swift
//  CLITests
//
//  Created by Jake Heiser on 9/14/17.
//

import TestingUtilities
import XCTest

class BuildTests: XCTestCase {
    
    func testSimpleBuild() {
        let icebox = IceBox(template: .exec)
        let result = icebox.run("build")
        IceAssertEqual(result.exitStatus, 0)
        IceAssertEqual(result.stderr, "")
        result.assertStdout { (t) in
            t.equals("Fetch https://github.com/jakeheis/SwiftCLI")
            t.equals("Clone https://github.com/jakeheis/SwiftCLI")
            t.equals("Resolve https://github.com/jakeheis/SwiftCLI at 4.1.2")
            t.equalsInAnyOrder(Set("""
                Compile SwiftCLI/ArgumentList.swift
                Compile SwiftCLI/ArgumentListManipulator.swift
                Compile SwiftCLI/CLI.swift
                Compile SwiftCLI/Command.swift
                Compile SwiftCLI/CommandSignature.swift
                Compile SwiftCLI/Compatibility.swift
                Compile SwiftCLI/CompletionGenerator.swift
                Compile SwiftCLI/Error.swift
                Compile SwiftCLI/HelpCommand.swift
                Compile SwiftCLI/HelpMessageGenerator.swift
                Compile SwiftCLI/Input.swift
                Compile SwiftCLI/Option.swift
                Compile SwiftCLI/ParameterFiller.swift
                Compile SwiftCLI/Path.swift
                Compile SwiftCLI/Router.swift
                Compile SwiftCLI/Term.swift
                Compile SwiftCLI/VersionCommand.swift
                Compile SwiftCLI/OptionGroup.swift
                Compile SwiftCLI/OptionRecognizer.swift
                Compile SwiftCLI/OptionRegistry.swift
                Compile SwiftCLI/Output.swift
                Compile SwiftCLI/OutputByteStream.swift
                Compile SwiftCLI/Parameter.swift
                """.split(separator: "\n").map(String.init)))
            t.equals("Merge SwiftCLI")
            t.equals("Compile Exec/main.swift")
            t.equals("Merge Exec")
            t.equals("Link Exec")
            t.empty()
            t.done()
        }
        
        XCTAssertTrue(icebox.fileExists(".build/debug/Exec"))
    }
    
    func testCleanBuild() {
        let icebox = IceBox(template: .lib)
        
        let initial = icebox.run("build", "-c")
        IceAssertEqual(initial.exitStatus, 0)
        IceAssertEqual(initial.stderr, "")
        IceAssertEqual(initial.stdout, """
        Compile Lib/Lib.swift
        Merge Lib

        """)
        
        let followup = icebox.run("build", "-c")
        IceAssertEqual(followup.exitStatus, 0)
        IceAssertEqual(followup.stderr, "")
        IceAssertEqual(initial.stdout, """
        Compile Lib/Lib.swift
        Merge Lib

        """)
        
        XCTAssertTrue(icebox.fileExists(".build/debug"))
    }
    
    func testReleaseBuild() {
        let icebox = IceBox(template: .lib)
        
        let initial = icebox.run("build", "-r")
        IceAssertEqual(initial.exitStatus, 0)
        IceAssertEqual(initial.stderr, "")
        IceAssertEqual(initial.stdout, """
        Compile Lib/Lib.swift
        """)
        
        XCTAssertTrue(icebox.fileExists(".build/release"))
        XCTAssertFalse(icebox.fileExists(".build/debug"))
    }
    
    func testBuildErrors() {
        let icebox = IceBox(template: .lib)
        
        let contents = """
        let str: String? = "text"
        print(str)

        let int: Int = "hello world"

        """
        icebox.createFile(path: "Sources/Lib/Lib.swift", contents: contents)
        
        let result = icebox.run("build")
        IceAssertEqual(result.exitStatus, 1)
        IceAssertEqual(result.stderr, "")
        IceAssertEqual(result.stdout, """
        Compile Lib/Lib.swift

          ● Error: expressions are not allowed at the top level
        
            print(str)
            ^
            at ./Sources/Lib/Lib.swift:2
        
        
          ● Warning: expression implicitly coerced from 'String?' to 'Any'

            print(str)
                  ^^^
            at ./Sources/Lib/Lib.swift:2

            Note: provide a default value to avoid this warning

            print(str)
                  ^^^
                      ?? <#default value#>

            at ./Sources/Lib/Lib.swift:2

            Note: force-unwrap the value to avoid this warning

            print(str)
                  ^^^
                     !

            at ./Sources/Lib/Lib.swift:2

            Note: explicitly cast to 'Any' with 'as Any' to silence this warning

            print(str)
                  ^^^
                      as Any

            at ./Sources/Lib/Lib.swift:2


          ● Error: cannot convert value of type 'String' to specified type 'Int'

            let int: Int = "hello world"
                           ^^^^^^^^^^^^^
            at ./Sources/Lib/Lib.swift:4
        
        
        """)
    }
    
    func testBuildTarget() {
        let success = IceBox(template: .lib).run("build", "--target=Lib")
        IceAssertEqual(success.exitStatus, 0)
        IceAssertEqual(success.stderr, "")
        IceAssertEqual(success.stdout, """
        Compile Lib/Lib.swift
        Merge Lib

        """)
        
        let error = IceBox(template: .lib).run("build", "--target=Library")
        IceAssertEqual(error.exitStatus, 1)
        IceAssertEqual(error.stdout, "")
        IceAssertEqual(error.stderr, """
        
        Error: no target named 'Library'

        
        """)
    }
    
    func testBuildProduct() {
        let result = IceBox(template: .exec).run("build", "--product=Exec")
        IceAssertEqual(result.exitStatus, 0)
        IceAssertEqual(result.stderr, "")
        IceAssertEqual(result.stdout?.components(separatedBy: "\n").suffix(from: 27).joined(separator: "\n"), """
        Compile Exec/main.swift
        Merge Exec
        Link Exec
        
        """)
        
        let result2 = IceBox(template: .lib).run("build", "--product=Prod")
        IceAssertEqual(result2.exitStatus, 1)
        IceAssertEqual(result2.stdout, "")
        IceAssertEqual(result2.stderr, """
        
        Error: no product named 'Prod'

        
        """)
    }
    
    func testBuildForward() {
        let result = IceBox(template: .lib).run("build", "--Xswiftc", "-swift-version", "--Xswiftc", "3")
        IceAssertEqual(result.exitStatus, 1)
        IceAssertEqual(result.stderr, "")
        IceAssertEqual(result.stdout, """
        Compile Lib/Lib.swift

          ● Error: invalid value '3' in '-swift-version 3'

            at <unknown>:0

            Note: valid arguments to '-swift-version' are '4', '4.2', '5'

            at <unknown>:0
        
        
        """)
    }
    
}
