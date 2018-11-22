//
//  GenerateTests.swift
//  Ice
//
//  Created by Samasaur on 11/3/18.
//

import IceKit
import SwiftCLI

class GenerateTestListCommand: IceObject, Command {
    
    let name = "generate-test-list"
    let shortDescription = "Generates Linux tests"
    
    func execute() throws {
        let package = try loadPackage()
        var testTargets: [String] = []
        for t in package.targets {
            if t.type == .test {
                testTargets.append(t.name)
            }
        }
        try SPM().generateTests(removing: testTargets.map({ $0 + "XCTestManifests.swift" }), verbose: verbose.value)
    }
}
