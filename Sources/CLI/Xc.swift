//
//  Xc.swift
//  Ice
//
//  Created by Jake Heiser on 7/22/17.
//

import SwiftCLI
import Core
import Exec

class XcCommand: Command {
    
    let name = "xc"
    let shortDescription = "Creates a new xcode project for the current package"
    
    let noOpen = Flag("-n", "--no-open")
    
    func execute() throws {
        try SPM().generateXcodeProject()
        
        if noOpen.value {
            return
        }
        
        let package = try Package.load(directory: ".")
        do {
            try Exec(command: "open", args: ["\(package.name).xcodeproj"]).execute()
        } catch {}
    }
    
}
