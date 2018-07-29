//
//  ToolsVersion.swift
//  Ice
//
//  Created by Jake Heiser on 7/28/18.
//

import IceKit
import SwiftCLI

class ToolsVersionGroup: CommandGroup {
    let name = "tools-version"
    let shortDescription = "Manage the current project's Swift tools version"
    let children: [Routable] = [
        GetToolsVersion(),
        UpdateToolsVersion()
    ]
}

class GetToolsVersion: Command {
    
    let name = "get"
    let shortDescription = "Get the current project's Swift tools version"
    
    func execute() throws {
        let package = try Package.load()
        stdout <<< "Swift tools version: \(package.toolsVersion)"
    }
    
}

class UpdateToolsVersion: Command {
    
    let name = "update"
    let shortDescription = "Update the current project's Swift tools version"
    
    let version = Parameter()
    
    func execute() throws {
        
    }
    
}
