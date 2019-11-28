//
//  ToolsVersion.swift
//  Ice
//
//  Created by Jake Heiser on 7/28/18.
//

import IceKit
import PathKit
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
    let shortDescription = "Update the current project's Swift tools version and migrate Package.swift to the new version"
    
    @Flag("-t", "--tagged", description: "Tag the new package file with the version; e.g. create Package@swift-5.0.swift rather than overwrite Package.swift")
    var tagged: Bool
    
    @Param(completion: .values([
        ("4.0", ""),
        ("4.2", ""),
        ("5.0", ""),
    ]))
    var version: String
    
    func execute() throws {
        guard let toolsVersion = SwiftToolsVersion(version) else {
            throw IceError(message: "invalid tools version")
        }
        
        var package = try loadPackage()
        package.toolsVersion = toolsVersion
        
        let toolsVersionString = tagged ? toolsVersion.description : nil
        package.path = PackageFile.formPackagePath(in: package.path.parent(), versionTag: toolsVersionString)
        
        try package.sync()
    }
    
}
