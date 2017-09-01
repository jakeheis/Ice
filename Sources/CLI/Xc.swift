//
//  Xc.swift
//  Ice
//
//  Created by Jake Heiser on 7/22/17.
//

import Foundation
import SwiftCLI
import Core

class XcCommand: Command {
    
    let name = "xc"
    
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
