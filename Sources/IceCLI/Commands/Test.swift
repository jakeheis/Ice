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
    
    let generate = Flag("--generate-list", description: "Generate Linux tests instead of testing", defaultValue: false)
    let filter = OptionalParameter()
    
    func execute() throws {
        if generate.value {
            let package = try loadPackage()
            var testTargets: [String] = []
            for t in package.targets {
                if t.type == .test {
                    testTargets.append(t.name)
                }
            }
            try SPM().generateTests(removing: testTargets.map({ $0 + "XCTestManifests.swift" }), verbose: verbose.value)
        } else {
            try SPM().test(filter: filter.value)
        }
    }
    
}
