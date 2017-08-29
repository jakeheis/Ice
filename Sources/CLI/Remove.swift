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
    let package = Parameter()
    
    let global = GlobalOption.global
    let purge = Flag("-p", "--purge")

    func execute() throws {
        if global.value {
            try Global.remove(name: package.value, purge: purge.value)
        } else {
            var project = try Package.load(directory: ".")
            try project.removeDependency(named: package.value)
            try project.write()
        }
    }
    
}
