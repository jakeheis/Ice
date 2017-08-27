//
//  Module.swift
//  Ice
//
//  Created by Jake Heiser on 7/22/17.
//

import SwiftCLI

class ModuleCommand: Command {
    
    let name = "module"
    let moduleName = Parameter()

    let dependencies = Key<String>("-d", "--depends-on")
    
    func execute() throws {
        
    }
    
}
