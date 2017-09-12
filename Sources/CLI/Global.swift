//
//  Global.swift
//  CLI
//
//  Created by Jake Heiser on 9/12/17.
//

import SwiftCLI
import Core

class GlobalGroup: CommandGroup {
    let name = "global"
    let shortDescription = "The group of global commands"
    let children: [Routable] = [
        GlobalAddCommand(), GlobalUpgradeCommand(), GlobalRemoveCommand()
    ]
}

class GlobalAddCommand: Command {
    
    let name = "add"
    let shortDescription = "Install a global package"
    
    let package = Parameter()
    let version = OptionalParameter()
    
    func execute() throws {
        guard let ref = RepositoryReference(package.value) else {
            throw IceError(message: "not a valid package reference")
        }
        
        let version = try ref.latestVersion()
        
        try Global.add(ref: ref, version: version)
    }
    
}

class GlobalUpgradeCommand: Command {
    
    let name = "upgrade"
    let shortDescription = "Upgrades the given global package"
    
    let package = Parameter()
    let version = OptionalParameter()
    
    func execute() throws {
        let version: Version?
        if let versionString = self.version.value {
            version = Version(versionString)
        } else {
            version = nil
        }
        try Global.upgrade(name: package.value, version: version)
    }
    
}

class GlobalRemoveCommand: Command {
    
    let name = "remove"
    let shortDescription = "Removes the given global package"
    
    let package = Parameter()
    
    func execute() throws {
       try Global.remove(name: package.value)
    }
    
}
