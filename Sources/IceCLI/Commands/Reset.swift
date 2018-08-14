//
//  Reset.swift
//  Ice
//
//  Created by Jake Heiser on 9/6/17.
//

import IceKit
import SwiftCLI

class ResetCommand: Command {
    
    let name = "reset"
    let shortDescription = "Resets the current package"
    
    func execute() throws {
        try SPM().reset()
    }
    
}
