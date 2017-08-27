//
//  Build.swift
//  Ice
//
//  Created by Jake Heiser on 7/22/17.
//

import SwiftCLI
import Core

class BuildCommand: Command {
    
    let name = "build"
    
    let clean = Flag("-c", "--clean")
    let release = Flag("-r", "--release")
    let watch = Flag("-w", "--watch")
    
    func execute() throws {
        if clean.value {
            try SPM().clean()
        }
        try SPM().build()
    }
    
}
