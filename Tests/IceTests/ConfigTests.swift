//
//  ConfigTests.swift
//  CLITests
//
//  Created by Jake Heiser on 9/13/17.
//

import Foundation
import TestingUtilities
import XCTest

class ConfigTests: XCTestCase {
    
    func testGet() {
        let reformatResult = IceBox(template: .empty).run("config", "get", "reformat")
        IceAssertEqual(reformatResult.exitStatus, 0)
        IceAssertEqual(reformatResult.stderr, "")
        IceAssertEqual(reformatResult.stdout, """
        false

        """)
        
        let icebox = IceBox(template: .empty)
        icebox.createFile(path: "global/config.json", contents: "{\n  \"reformat\" : true\n}")
        let globalResult = icebox.run("config", "get", "reformat")
        IceAssertEqual(globalResult.exitStatus, 0)
        IceAssertEqual(globalResult.stderr, "")
        IceAssertEqual(globalResult.stdout, """
        true

        """)
    }
    
    func testSet() {
        let icebox = IceBox(template: .empty)
        
        let reformatResult = icebox.run("config", "set", "reformat", "true")
        IceAssertEqual(reformatResult.exitStatus, 0)
        IceAssertEqual(reformatResult.stderr, "")
        IceAssertEqual(reformatResult.stdout, "")
        
        let object = try! JSONSerialization.jsonObject(with: icebox.fileContents("global/config.json")!, options: []) as! [String: Bool]
        IceAssertEqual(object, [
            "reformat": true,
        ])
    }
    
    func testSetInvalid() {
        let result = IceBox(template: .empty).run("config", "set", "email", "hi@hi.com")
        IceAssertEqual(result.exitStatus, 1)
        IceAssertEqual(result.stdout, "")
        IceAssertEqual(result.stderr, """
        
        Error: unrecognized config key

        Valid keys:
        
          reformat     whether Ice should organize your Package.swift (alphabetize, etc.); defaults to false
          openAfterXc  whether Ice should open Xcode the generated project after running `ice xc`; defaults to true

        
        """)
    }
    
    func testShow() {
        let result = IceBox(template: .empty).run("config", "show")
        IceAssertEqual(result.exitStatus, 0)
        IceAssertEqual(result.stderr, "")
        IceAssertEqual(result.stdout, """
        +-------------+--------+--------+----------+
        | Key         | Local  | Global | Resolved |
        +-------------+--------+--------+----------+
        | reformat    | (none) | false  | false    |
        | openAfterXc | (none) | true   | true     |
        +-------------+--------+--------+----------+
        
        """)
    }
    
}
