//
//  Xc.swift
//  Ice
//
//  Created by Jake Heiser on 7/22/17.
//

import SwiftCLI

class XcodeCommand: Command {
    
    let name = "xc"
    
    func execute() throws {
        try SPM.execute(arguments: ["package", "generate-xcodeproj"])
    }
    
}
