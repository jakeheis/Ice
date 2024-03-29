//
//  Test.swift
//  Ice
//
//  Created by Jake Heiser on 7/22/17.
//

import IceKit
import SwiftCLI

class TestCommand: ForwardFlagsCommand, Command {
    
    let name = "test"
    let shortDescription = "Tests the current package"
    let longDescription = """
    Tests the current package. Takes an optional filter argument of the
    form [<test-target>].[<test-case>][/<test>] (e.g. `ice test IceKitTests.AddTests/testTargetAdd`)
    """
    
    @Param var filter: String?
    
    func execute() throws {
        try SPM().test(filter: filter, forwardArguments: forwardArguments)
    }
    
}
