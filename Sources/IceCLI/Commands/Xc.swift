//
//  Xc.swift
//  Ice
//
//  Created by Jake Heiser on 7/22/17.
//

import IceKit
import SwiftCLI

class XcCommand: IceObject, Command {
    
    let name = "xc"
    let shortDescription = "Creates a new xcode project for the current package"
    
    let noOpen = Flag("-n", "--no-open", description: "Don't open the Xcode project after generating it")
    
    func execute() throws {
        try SPM().generateXcodeProject()
        
        if noOpen.value || config.resolved.openAfterXc == false {
            return
        }
        
        let package = try loadPackage()
        do {
            try run("open", "\(package.name).xcodeproj")
        } catch {}
    }
    
}
