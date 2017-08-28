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
        var package = try Package.load(directory: ".")
        
        if package.targets.contains(where: { $0.name == targetName.value }) {
            throw SwiftProcess.Error.processFailed
        }
        
        let intermediateFolder: Folder
        if isTest.value {
            intermediateFolder = try Folder.current.createSubfolderIfNeeded(withName: "Tests")
        } else {
            intermediateFolder = try Folder.current.createSubfolderIfNeeded(withName: "Sources")
        }
        let targetFolder = try intermediateFolder.createSubfolderIfNeeded(withName: targetName.value)
        if targetFolder.files.first == nil {
            let initialFile = "//\n// \(targetName.value).swift\n//\n"
            try targetFolder.createFile(named: targetName.value + ".swift", contents: initialFile)
        }
        
        package.addTarget(
            name: targetName.value,
            isTest: isTest.value,
            dependencies: dependencies.value?.commaSeparated() ?? []
        )
        try package.write()
    }
    
}
