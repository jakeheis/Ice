//
//  Clean.swift
//  IcePackageDescription
//
//  Created by Jake Heiser on 8/27/17.
//

import IceKit
import SwiftCLI

class CleanCommand: Command {
    
    let name = "clean"
    let shortDescription = "Cleans the current project"
    
    func execute() throws {
        try SPM().clean()
    }
    
}
