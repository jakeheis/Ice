//
//  New.swift
//  Bark
//
//  Created by Jake Heiser on 7/21/17.
//

import SwiftCLI
import Core
import FileKit

class NewCommand: Command {

    let name = "new"
    let shortDescription = "Creates a new package in the given directory"
    
    let projectName = Parameter()

    let library = InitializerOptions.library
    let executable = InitializerOptions.executable
    let optionGroups = [InitializerOptions.typeGroup]

    func execute() throws {
        let path = Path.current + projectName.value
        if path.exists {
            throw IceError(message: "\(projectName.value) already exists")
        }
        try path.createDirectory()
        
        Path.current = path
        var type: SPM.InitType?
        if library.value {
            type = .library
        } else if executable.value {
            type = .executable
        }
        try SPM().initPackage(type: type)
        
        // Reformat
        let p = try Package.load()
        try p.write()
        
        stdout <<< ""
        stdout <<< "Run: ".blue.bold + "cd \(projectName.value) && ice build"
        stdout <<< ""
    }

}
