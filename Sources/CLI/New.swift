//
//  New.swift
//  Bark
//
//  Created by Jake Heiser on 7/21/17.
//

import SwiftCLI

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
//        Folder.current.createSubfolderIfNeeded(withName: projectName.value)
        // Change dir to new folder
        var initArgs: [String] = []
        if library.value {
            initArgs.append(library.names[0])
        }
        if executable.value {
            initArgs.append(executable.names[0])
        }
        // InitCommand().manualExecute(initArgs)
    }

}
