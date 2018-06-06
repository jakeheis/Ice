//
//  Remove.swift
//  Ice
//
//  Created by Jake Heiser on 7/22/17.
//

import SwiftCLI
import Core

class RemoveCommand: Command {
    
    let name = "remove"
    let shortDescription = "Removes a dependency from the current package"
    
    let package = Parameter()

    func execute() throws {
        var project = try Package.load()
        try project.removeDependency(named: package.value)
        try project.write()
    }
    
}
