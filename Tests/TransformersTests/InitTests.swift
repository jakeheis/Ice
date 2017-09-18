//
//  InitTests.swift
//  TransformersTests
//
//  Created by Jake Heiser on 9/17/17.
//

import XCTest
import Transformers

class InitTests: XCTestCase {
    
    func testCreatePackage() {
        let build = TransformTest(Transformers.initPackage)
        build.send(.out, """
        Creating library package: Ice
        """)
        build.expect(stdout: """
        
        Creating library package: Ice

        
        
        """, stderr: "")
    }
    
    func testCreateFiles() {
        let build = TransformTest(Transformers.initPackage)
        build.send(.out, """
        Creating Package.swift
        Creating README.md
        Creating .gitignore
        Creating Sources/
        Creating Sources/MyNewLib/MyNewLib.swift
        Creating Tests/
        Creating Tests/LinuxMain.swift
        Creating Tests/MyNewLibTests/
        Creating Tests/MyNewLibTests/MyNewLibTests.swift
        """)
        build.expect(stdout: """
        
            create Package.swift
            create README.md
            create .gitignore
            create Sources/
            create Sources/MyNewLib/MyNewLib.swift
            create Tests/
            create Tests/LinuxMain.swift
            create Tests/MyNewLibTests/
            create Tests/MyNewLibTests/MyNewLibTests.swift
        
        
        """, stderr: "")
    }
    
}
