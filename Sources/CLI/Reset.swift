//
//  Reset.swift
//  CLI
//
//  Created by Jake Heiser on 9/6/17.
//

import SwiftCLI
import Core

class ResetCommand: Command {
    
    let name = "reset"
    
    func execute() throws {
        try SPM().reset()
    }
    
}
