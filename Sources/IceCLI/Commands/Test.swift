//
//  Test.swift
//  Ice
//
//  Created by Jake Heiser on 7/22/17.
//

import IceKit
import SwiftCLI

class TestCommand: IceObject, Command {
    
    let name = "test"
    let shortDescription = "Tests the current package"
    let longDescription = """
    Tests the current package. Takes an optional filter argument of the
    form [<test-target>].[<test-case>][/<test>] (e.g. `ice test IceKitTests.AddTests/testTargetAdd`)
    """
    
    @OptParam var filter: String?
    
    @Flag("--generate-list", description: "Generate Linux test list instead of testing")
    var generate: Bool
    
    func execute() throws {
        if generate {
            let package = try loadPackage()
            try SPM().generateTests(for: package.targets)
        } else {
            try SPM().test(filter: filter)
        }
    }
    
}
