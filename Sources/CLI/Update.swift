//
//  File.swift
//  CLI
//
//  Created by Jake Heiser on 9/25/17.
//

import SwiftCLI
import Core

class UpdateCommand: Command {
    
    let name = "update"
    let shortDescription = "Update the current package's dependencies"
    
    func execute() throws {
        try SPM().update()
    }
    
}
