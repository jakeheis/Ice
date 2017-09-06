//
//  New.swift
//  Bark
//
//  Created by Jake Heiser on 7/21/17.
//

import SwiftCLI
import Core
import Files

struct GlobalOption {
    static let global = Flag("-G", "--global")
}

struct InitializerOptions {
    static let library = Flag("-l", "--lib", "--library")
    static let executable = Flag("-e", "--exec", "--executable")
    static let typeGroup =  OptionGroup(options: [library, executable], restriction: .atMostOne)
}

class NewCommand: Command {

    let name = "new"
    let projectName = Parameter()

    let library = InitializerOptions.library
    let executable = InitializerOptions.executable
    let optionGroups = [InitializerOptions.typeGroup]

    func execute() throws {
        try Folder.current.createSubfolderIfNeeded(withName: projectName.value)
        
        var type: SPM.InitType?
        if library.value {
            type = .library
        } else if executable.value {
            type = .executable
        }
        try SPM(path: projectName.value).initPackage(type: type)
        
        print("Run: ".blue.bold + "cd \(projectName.value) && ice build")
        print()
    }

}
