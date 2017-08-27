//
//  Module.swift
//  Ice
//
//  Created by Jake Heiser on 7/22/17.
//

import SwiftCLI
import Core
// import Files

class ModuleCommand: Command {
    
    let name = "module"
    let moduleName = Parameter()

    let dependencies = Key<String>("-d", "--depends-on")
    
    func execute() throws {
        let package = try Package()
        // package.folder.createSubfolder(moduleName.value)
        // let dependencies = dependencies.value?.componentsSeparated(by: ",") ?? []
        // try package.createTarget(name: moduleName.value, dependencies: dependencies)
    }
    
}
