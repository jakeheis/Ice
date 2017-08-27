//
//  Xc.swift
//  Ice
//
//  Created by Jake Heiser on 7/22/17.
//

import SwiftCLI
import Core

class XcCommand: Command {
    
    let name = "xc"
    
    func execute() throws {
        try SPM().generateXcodeProject()
    }
    
}
