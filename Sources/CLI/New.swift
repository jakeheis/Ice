//
//  New.swift
//  Bark
//
//  Created by Jake Heiser on 7/21/17.
//

import SwiftCLI
import Core
import FileKit

struct InitializerOptions {
    static let library = Flag("-l", "--lib", "--library")
    static let executable = Flag("-e", "--exec", "--executable")
    static let typeGroup =  OptionGroup(options: [library, executable], restriction: .atMostOne)
}

class NewCommand: Command {

    let name = "new"
    let shortDescription = "Creates a new package in the given directory"
    
    let projectName = Parameter()

    let library = InitializerOptions.library
    let executable = InitializerOptions.executable
    let optionGroups = [InitializerOptions.typeGroup]

    func execute() throws {
        let path = Path.current + projectName.value
        try path.createDirectory()
        
        var type: SPM.InitType?
        if library.value {
            type = .library
        } else if executable.value {
            type = .executable
        }
        try SPM(path: path).initPackage(type: type)
        
        stdout <<< ""
        stdout <<< "Run: ".blue.bold + "cd \(projectName.value) && ice build"
        stdout <<< ""
    }

}
