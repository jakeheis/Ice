//
//  GenerateTests.swift
//  Ice
//
//  Created by Samasaur on 11/3/18.
//

import IceKit
import SwiftCLI

class GenerateTestListCommand: Command {
    
    let name = "generate-test-list"
    let shortDescription = "Generates Linux tests"
    
    func execute() throws {
        try SPM().generateTests()
    }
}
