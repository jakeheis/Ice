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
    let shortDescription = "Removes a dependency from the current pacakge"
    
    let package = Parameter()

    func execute() throws {
        var project = try Package.load(directory: ".")
        try project.removeDependency(named: package.value)
        try project.write()
    }
    
}
