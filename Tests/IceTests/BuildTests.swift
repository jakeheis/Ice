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
        
        Differentiate.byVersion(swift5_1AndAbove: {
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
        }, swift4_0AndAbove: {
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
        })
        
        XCTAssertTrue(icebox.fileExists(".build/debug/Exec"))
    }
    
    func testCleanBuild() {
        let icebox = IceBox(template: .lib)
        
        let initial = icebox.run("build", "-c")
        IceAssertEqual(initial.exitStatus, 0)
        IceAssertEqual(initial.stderr, "")
        Differentiate.byVersion(swift5_1AndAbove: {
            IceAssertEqual(initial.stdout, """
            Compile Lib/Lib.swift
            Merge Lib

            """)
        }, swift4_0AndAbove: {
            IceAssertEqual(initial.stdout, """
            Compile Lib (1 sources)

            """)
        })
        
        let followup = icebox.run("build", "-c")
        IceAssertEqual(followup.exitStatus, 0)
        IceAssertEqual(followup.stderr, "")
        Differentiate.byVersion(swift5_1AndAbove: {
            IceAssertEqual(initial.stdout, """
            Compile Lib/Lib.swift
            Merge Lib

            """)
        }, swift4_0AndAbove: {
            IceAssertEqual(initial.stdout, """
            Compile Lib (1 sources)

            """)
        })
        
        XCTAssertTrue(icebox.fileExists(".build/debug"))
    }
    
    func testReleaseBuild() {
        let icebox = IceBox(template: .lib)
        
        let initial = icebox.run("build", "-r")
        IceAssertEqual(initial.exitStatus, 0)
        IceAssertEqual(initial.stderr, "")
        Differentiate.byVersion(swift5_1AndAbove: {
            IceAssertEqual(initial.stdout, """
            Compile Lib/Lib.swift
            """)
        }, swift4_0AndAbove: {
            IceAssertEqual(initial.stdout, """
            Compile Lib (1 sources)

            """)
        })
        
        XCTAssertTrue(icebox.fileExists(".build/release"))
        XCTAssertFalse(icebox.fileExists(".build/debug"))
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
        IceAssertEqual(result.exitStatus, 1)
        IceAssertEqual(result.stderr, "")
        
        Differentiate.byVersion(swift5_1AndAbove: {
            IceAssertEqual(result.stdout?.components(separatedBy: "\n").suffix(from: 29).joined(separator: "\n"), """
              ● Warning: expression implicitly coerced from 'String?' to 'Any'

                print(str)
                      ^^^
                at ./Sources/Exec/main.swift:2

                Note: provide a default value to avoid this warning

                print(str)
                      ^^^
                          ?? <#default value#>

                at ./Sources/Exec/main.swift:2

                Note: force-unwrap the value to avoid this warning

                print(str)
                      ^^^
                         !

                at ./Sources/Exec/main.swift:2

                Note: explicitly cast to 'Any' with 'as Any' to silence this warning

                print(str)
                      ^^^
                          as Any

                at ./Sources/Exec/main.swift:2


              ● Error: cannot convert value of type 'String' to specified type 'Int'

                let int: Int = "hello world"
                               ^^^^^^^^^^^^^
                at ./Sources/Exec/main.swift:4
            
            
            """)
        }, swift4_2AndAbove: {
            IceAssertEqual(result.stdout, """
            Fetch https://github.com/jakeheis/SwiftCLI
            Clone https://github.com/jakeheis/SwiftCLI
            Resolve https://github.com/jakeheis/SwiftCLI at 4.1.2
            Compile SwiftCLI (23 sources)
            Compile Exec (1 sources)

              ● Warning: expression implicitly coerced from 'String?' to 'Any'

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

                Note: explicitly cast to 'Any' with 'as Any' to silence this warning

                print(str)
                      ^^^
                          as Any

                at Sources/Exec/main.swift:2


              ● Error: cannot convert value of type 'String' to specified type 'Int'

                let int: Int = "hello world"
                               ^^^^^^^^^^^^^
                at Sources/Exec/main.swift:4
            
            
            """)
        }, swift4_0AndAbove: {
            IceAssertEqual(result.stdout, """
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
        })
    }
    
    func testBuildTarget() {
        let success = IceBox(template: .lib).run("build", "--target=Lib")
        IceAssertEqual(success.exitStatus, 0)
        IceAssertEqual(success.stderr, "")
        Differentiate.byVersion(swift5_1AndAbove: {
            IceAssertEqual(success.stdout, """
            Compile Lib/Lib.swift
            Merge Lib

            """)
        }, swift4_0AndAbove: {
            IceAssertEqual(success.stdout, """
            Compile Lib (1 sources)

            """)
        })
        
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
        Differentiate.byVersion(swift5_1AndAbove: {
            IceAssertEqual(result.stdout?.components(separatedBy: "\n").suffix(from: 27).joined(separator: "\n"), """
            Compile Exec/main.swift
            Merge Exec
            Link Exec
            
            """)
        }, swift4_0AndAbove: {
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
        })
        
        let result2 = IceBox(template: .exec).run("build", "--product=Prod")
        IceAssertEqual(result2.exitStatus, 1)
        IceAssertEqual(result2.stdout, """
        Fetch https://github.com/jakeheis/SwiftCLI
        Clone https://github.com/jakeheis/SwiftCLI
        Resolve https://github.com/jakeheis/SwiftCLI at 4.1.2
        
        """)
        IceAssertEqual(result2.stderr, """
        
        Error: no product named 'Prod'

        
        """)
    }
    
}
