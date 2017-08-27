//
//  Clean.swift
//  IcePackageDescription
//
//  Created by Jake Heiser on 8/27/17.
//

import SwiftCLI
import Core

class CleanCommand: Command {
    
    let name = "clean"
    
    func execute() throws {
        try SPM().clean()
    }
    
}
