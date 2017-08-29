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
        let open = Process()
        open.launchPath = "/usr/bin/env"
        open.arguments = ["open", "\(package.name).xcodeproj"]
        open.launch()
        open.waitUntilExit()
    }
    
}
