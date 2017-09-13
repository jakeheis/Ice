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
        
        let packageVersion: Version?
        if let versionValue = version.value {
            guard let specifiedVersion = Version(versionValue) else {
                throw IceError(message: "invalid version")
            }
            packageVersion = specifiedVersion
        } else {
            packageVersion = nil
        }
        
        try Global.add(ref: ref, version: packageVersion)
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
