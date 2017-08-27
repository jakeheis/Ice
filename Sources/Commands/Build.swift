//
//  Build.swift
//  Ice
//
//  Created by Jake Heiser on 7/22/17.
//

import SwiftCLI

class BuildCommand: Command {
    
    let name = "build"
    
    let clean = Flag("-c", "--clean")
    let release = Flag("-r", "--release")
    let watch = Flag("-w", "--watch")
    
    func execute() throws {
        try SPM.execute(arguments: ["build"])
    }
    
}
