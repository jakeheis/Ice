//
//  XcodeCommand.swift
//  Bark
//
//  Created by Jake Heiser on 7/22/17.
//

import SwiftCLI

class XcodeCommand: Command {
    
    let name = "xcode"
    
    func execute() throws {
        try SPM.execute(arguments: ["package", "generate-xcodeproj"])
    }
    
}
