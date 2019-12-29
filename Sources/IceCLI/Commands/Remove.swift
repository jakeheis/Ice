//
//  Remove.swift
//  Ice
//
//  Created by Jake Heiser on 7/22/17.
//

import IceKit
import PathKit
import SwiftCLI

class RemoveCommand: IceObject, Command {
    
    let name = "remove"
    let shortDescription = "Removes a dependency from the current package"
    
    @Param(completion: .function(.listDependencies))
    var dependency: String
    
    func execute() throws {
        var package = try loadPackage()
        
        guard let dependency = package.getDependency(named: dependency) else {
            throw IceError(message: "dependency '\(self.dependency)' not found")
        }
        
        if package.checkoutDirectories(forDependency: dependency).isEmpty {
            Logger.verbose <<< "Checking out dependency so it can be fully removed"
            do {
                try SPM().resolve(silent: true)
            } catch {}
        }
        
        package.removeDependency(dependency)
        
        try package.sync()
    }
    
}
