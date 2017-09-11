//
//  Upgrade.swift
//  Ice
//
//  Created by Jake Heiser on 7/22/17.
//

import SwiftCLI
import Core

class UpgradeCommand: Command {
    
    let name = "upgrade"
    let shortDescription = "Upgrades the given package"
    
    let dependency = Parameter()
    let version = OptionalParameter()

    let global = GlobalOption.global
    
    func execute() throws {
        let version: Version?
        if let versionString = self.version.value {
            version = Version(versionString)
        } else {
            version = nil
        }
        if global.value {
            try Global.upgrade(name: dependency.value, version: version)
        }
    }
    
}
