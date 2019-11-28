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
    
    @Param(completion: .function(.listDependencies))
    var dependency: String
    
    func execute() throws {
        // Resolve first so that .build/checkouts is populated for use in Package.retrieveLibrariesOfDependency
        try SPM().resolve(silent: true)
        
        var package = try loadPackage()
        
        guard let dependency = package.getDependency(named: dependency) else {
            throw IceError(message: "dependency '\(self.dependency)' not found")
        }
        
        package.removeDependency(dependency)
        
        try package.sync()
    }
    
}
