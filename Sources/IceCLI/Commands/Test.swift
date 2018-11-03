//
//  Test.swift
//  Ice
//
//  Created by Jake Heiser on 7/22/17.
//

import IceKit
import SwiftCLI

class TestCommand: Command {
    
    let name = "test"
    let shortDescription = "Tests the current package"
    let longDescription = """
    Tests the current package. Takes an optional filter argument of the
    form [<test-target>].[<test-case>][/<test>] (e.g. `ice test IceKitTests.AddTests/testTargetAdd`)
    """
    
    let generate = Flag("-g", "--generate", description: "Generate Linux tests instead of testing", defaultValue: false)
    let filter = OptionalParameter()
    
    func execute() throws {
        if generate.value {
            try SPM().generateTests()
        } else {
            try SPM().test(filter: filter.value)
        }
    }
    
}
