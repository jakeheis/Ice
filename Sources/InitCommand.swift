//
//  InitCommand.swift
//  Bark
//
//  Created by Jake Heiser on 7/21/17.
//

import SwiftCLI
import Files

class InitCommand: Command {
    
    let name = "init"
    let projectName = OptionalParameter()
    
    let library = Flag("-l", "--library")
    let executable = Flag("-e", "--executable")
    
    var optionGroups: [OptionGroup] {
        return [
            OptionGroup(options: [library, executable], restriction: .atMostOne)
        ]
    }
    
    func execute() throws {
        var args = ["package"]
        
        if let projectName = projectName.value {
            try Folder.current.createSubfolderIfNeeded(withName: projectName)
            args += ["-C", projectName]
        }
        
        args.append("init")
        
        if executable.value {
            args += ["--type", "executable"]
        }
        try SPM.execute(arguments: args)
        
        try Package(directory: projectName.value ?? ".").write()
    }
    
}

class TakeoverCommand: Command {
    
    let name = "takeover"
    
    func execute() throws {
        try Package().write()
    }
    
}
