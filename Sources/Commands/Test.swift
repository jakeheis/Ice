//
//  Test.swift
//  Ice
//
//  Created by Jake Heiser on 7/22/17.
//

import SwiftCLI

class TestCommand: Command {
    
    let name = "test"
    
    func execute() throws {
        try SPM().test()
    }
    
}
