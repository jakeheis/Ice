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
    
    @Flag("-n", "--no-open", description: "Don't open the Xcode project after generating it")
    var noOpen: Bool
    
    @Flag("-c", "--code-coverage", description: "Generate Xcode project with code coverage")
    var codeCoverage: Bool
    
    func execute() throws {
        try SPM().generateXcodeProject(codeCoverage: codeCoverage)
        
        if noOpen || config.resolved.openAfterXc == false {
            return
        }
        
        let package = try loadPackage()
        do {
            try Task.run("open", "\(package.name).xcodeproj")
        } catch {}
    }
    
}
