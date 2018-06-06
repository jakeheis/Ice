//
//  Version.swift
//  CLI
//
//  Created by Jake Heiser on 6/5/18.
//

import Core
import Regex
import SwiftCLI

class VersionCommand: Command {
    let name = "version"
    let shortDescription = "Prints the current version of Ice"
    
    func execute() throws {
        stdout <<< "Ice version: \(Ice.version)"
        
        let swiftFull = try capture("swift", "--version").stdout.trimmed
        if let match = Regex("Swift version ([0-9]\\.[0-9])").firstMatch(in: swiftFull) {
            stdout <<< "Swift version: " + match.captures[0]!
        }
    }
}
