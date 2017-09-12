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
        
    func execute() throws {
        
    }
    
}
