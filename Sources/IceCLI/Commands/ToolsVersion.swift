//
//  ToolsVersion.swift
//  Ice
//
//  Created by Jake Heiser on 7/28/18.
//

import IceKit
import SwiftCLI

class ToolsVersionGroup: IceObject, CommandGroup {
    let name = "tools-version"
    let shortDescription = "Manage the current project's Swift tools version"
    lazy var children: [Routable] = [
        GetToolsVersion(ice: ice),
        UpdateToolsVersion(ice: ice)
    ]
}

class GetToolsVersion: IceObject, Command {
    
    let name = "get"
    let shortDescription = "Get the current project's Swift tools version"
    
    func execute() throws {
        let package = try loadPackage()
        stdout <<< "Swift tools version: \(package.toolsVersion)"
    }
    
}

class UpdateToolsVersion: IceObject, Command {
    
    let name = "update"
    let shortDescription = "Update the current project's Swift tools version"
    
    let version = Parameter()
    
    func execute() throws {
        guard let toolsVersion = SwiftToolsVersion(version.value) else {
            throw IceError(message: "invalid tools version")
        }
        
        var package = try loadPackage()
        package.toolsVersion = toolsVersion
        try package.sync()
    }
    
}
