//
//  Resolve.swift
//  CLI
//
//  Created by Jake Heiser on 3/28/18.
//

import SwiftCLI
import Core

class ResolveCommand: Command {
    
    let name = "resolve"
    let shortDescription = "Resolve package dependencies"
    
    func execute() throws {
        try SPM().resolve()
    }
    
}
