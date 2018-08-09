//
//  Remove.swift
//  Ice
//
//  Created by Jake Heiser on 7/22/17.
//

import IceKit
import SwiftCLI

class RemoveCommand: IceObject, Command {
    
    let name = "remove"
    let shortDescription = "Removes a dependency from the current package"
    
    let package = Parameter(completion: .function(.listDependencies))

    func execute() throws {
        // Resolve first so that .build/checkouts is populated for use in Package.retrieveLibrariesOfDependency
        try SPM().resolve(silent: true)
        
        var project = try loadPackage()
        try project.removeDependency(named: package.value)
        try project.sync()
    }
    
}
