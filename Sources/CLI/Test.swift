//
//  Test.swift
//  Ice
//
//  Created by Jake Heiser on 7/22/17.
//

import SwiftCLI
import Core

class TestCommand: Command {
    
    let name = "test"
    let shortDescription = "Tests the current package"
    
    let filter = OptionalParameter()
    
    func execute() throws {
        try SPM().test(filter: filter.value)
    }
    
}
