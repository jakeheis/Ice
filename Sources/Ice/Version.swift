//
//  Version.swift
//  Ice
//
//  Created by Jake Heiser on 6/5/18.
//

import IceKit
import Regex
import SwiftCLI

class VersionCommand: IceObject, Command {
    
    let name = "version"
    let shortDescription = "Prints the current version of Ice"
    
    func execute() throws {
        stdout <<< "Ice version: \(ice.version)"
        
        let swiftFull = try capture("swift", "--version").stdout
        if let match = Regex("Swift version ([0-9]\\.[0-9](\\.[0-9])?) ").firstMatch(in: swiftFull) {
            stdout <<< "Swift version: " + match.captures[0]!
        }
    }
    
}
