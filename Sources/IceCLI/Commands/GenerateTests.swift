//
//  GenerateTests.swift
//  Ice
//
//  Created by Samasaur on 11/3/18.
//

import IceKit
import SwiftCLI

class GenerateTestsCommand: Command {
    
    let name = "generate-tests"
    let shortDescription = "Generates Linux tests"
    
    func execute() throws {
        try SPM().generateTests()
    }
}
