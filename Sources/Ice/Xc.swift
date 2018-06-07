//
//  Xc.swift
//  Ice
//
//  Created by Jake Heiser on 7/22/17.
//

import IceKit
import SwiftCLI

class XcCommand: Command {
    
    let name = "xc"
    let shortDescription = "Creates a new xcode project for the current package"
    
    let noOpen = Flag("-n", "--no-open")
    
    func execute() throws {
        try SPM().generateXcodeProject()
        
        if !noOpen.value {
            let package = try Package.load()
            do {
                try run("open", "\(package.name).xcodeproj")
            } catch {}
        }
    }
    
}
