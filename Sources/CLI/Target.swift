//
//  Target.swift
//  Ice
//
//  Created by Jake Heiser on 7/22/17.
//

import SwiftCLI
import Core
import Files

class TargetCommand: Command {
    
    let name = "target"
    let targetName = Parameter()

    let isTest = Flag("-t", "--test")
    let dependencies = Key<String>("-d", "--depends-on")
    
    func execute() throws {
        let intermediateFolder: Folder
        if isTest.value {
            intermediateFolder = try Folder.current.createSubfolderIfNeeded(withName: "Tests")
        } else {
            intermediateFolder = try Folder.current.createSubfolderIfNeeded(withName: "Sources")
        }
        try intermediateFolder.createSubfolderIfNeeded(withName: targetName.value)
        
        var package = try Package.load(directory: ".")
        package.addTarget(
            name: targetName.value,
            isTest: isTest.value,
            dependencies: dependencies.value?.commaSeparated() ?? []
        )
        try package.write()
    }
    
}
