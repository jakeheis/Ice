//
//  Version.swift
//  Ice
//
//  Created by Jake Heiser on 6/5/18.
//

import IceKit
import SwiftCLI

class VersionCommand: Command {
    
    let name = "version"
    let shortDescription = "Prints the current version of Ice"
    
    func execute() throws {
        stdout <<< "Ice version: \(Ice.version)"
        
        if let swiftVersion = SPM().version?.string {
            stdout <<< "Swift version: " + swiftVersion
        } else {
            throw IceError(message: "couldn't retrieve Swift version")
        }
    }
    
}
