//
//  InitTransformTests.swift
//  IceKitTests
//
//  Created by Jake Heiser on 9/17/17.
//

import XCTest
@testable import IceKit

class InitTransformTests: XCTestCase {
    
    func testCreatePackage() {
        let build = createTest()
        build.send("""
        Creating library package: Ice
        """)
        build.expect("""
        
        Creating library package: Ice
        
        
        """)
    }
    
    func testCreateFiles() {
        let build = createTest()
        build.send("""
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
        build.expect("""
            create Package.swift
            create README.md
            create .gitignore
            create Sources/
            create Sources/MyNewLib/MyNewLib.swift
            create Tests/
            create Tests/LinuxMain.swift
            create Tests/MyNewLibTests/
            create Tests/MyNewLibTests/MyNewLibTests.swift
        
        """)
    }
    
    private func createTest() -> TransformerTest {
        return TransformerTest(transformer: InitOut(), isStdout: true)
    }
    
}
