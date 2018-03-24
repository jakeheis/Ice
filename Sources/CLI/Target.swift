//
//  Target.swift
//  Ice
//
//  Created by Jake Heiser on 7/22/17.
//

import SwiftCLI
import Core
import FileKit

class TargetGroup: CommandGroup {
    let name = "target"
    let shortDescription = "Manage the package targets"
    let children: [Routable] = [
        TargetAddCommand(),
        TargetRemoveCommand()
    ]
}

private class TargetAddCommand: Command {
    
    let name = "add"
    let shortDescription = "Add a new target"
    
    let targetName = Parameter()

    let isTest = Flag("-t", "--test", description: "Marks this target as a test target")
    let dependencies = Key<String>("-d", "--dependencies", description: "Creates the new target with the given dependencies; comma-separated")
    
    func execute() throws {
        var package = try Package.load(directory: ".")
        
        if package.targets.contains(where: { $0.name == targetName.value }) {
            throw IceError(message: "target \(targetName.value) already exists")
        }
        
        var testTarget = isTest.value
        if !testTarget && targetName.value.contains("Test") {
            stdout <<< ""
            stdout <<< "Warning: ".yellow.bold + "Target name contains the word `Tests` but --test was not passed."
            stdout <<< ""
            stdout <<< "Is this target a test target? [y/N]"
            testTarget = Input.readBool(prompt: "> ")
        }
        
        let intermediatePath = Path.current + (testTarget ? "Tests" : "Sources")
        try intermediatePath.createDirectory(withIntermediateDirectories: true)
        
        let targetPath = intermediatePath + targetName.value
        try targetPath.createDirectory()
        
        let initialFile = targetPath + Path(targetName.value + ".swift")
        try "//\n// \(targetName.value).swift\n// \(package.name)\n//\n".write(to: initialFile)
        
        package.addTarget(
            name: targetName.value,
            isTest: testTarget,
            dependencies: dependencies.value?.commaSeparated() ?? []
        )
        try package.write()
    }
    
}

private class TargetRemoveCommand: Command {
    
    let name = "remove"
    
    let target = Parameter()
    
    func execute() throws {
        var project = try Package.load(directory: ".")
        try project.removeTarget(named: target.value)
        try project.write()
    }
    
}
