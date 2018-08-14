//
//  Format.swift
//  Ice
//
//  Created by Jake Heiser on 8/5/18.
//

import IceKit
import SwiftCLI

class FormatCommand: IceObject, Command {
    
    let name = "format"
    let shortDescription = "Format the Package.swift file (alphabetize, etc.)"
    
    func execute() throws {
        var package = try loadPackage()
        package.dirty = true
        try package.sync(format: true)
    }
    
}
