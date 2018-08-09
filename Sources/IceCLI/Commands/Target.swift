//
//  Target.swift
//  Ice
//
//  Created by Jake Heiser on 7/22/17.
//

import IceKit
import PathKit
import SwiftCLI

class TargetGroup: IceObject, CommandGroup {
    let name = "target"
    let shortDescription = "Manage the package targets"
    lazy var children: [Routable] = [
        TargetAddCommand(ice: ice),
        TargetRemoveCommand(ice: ice)
    ]
}

private class TargetAddCommand: IceObject, Command {
    
    let name = "add"
    let shortDescription = "Add a new target"
    
    let targetName = Parameter(completion: .none)

    let isTest = Flag("-t", "--test", description: "Marks this target as a test target")
    let dependencies = Key<String>("-d", "--dependencies", description: "Creates the new target with the given dependencies; comma-separated")
    
    func execute() throws {
        var package = try loadPackage()
        
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
        
        let targetPath = Path.current + (testTarget ? "Tests" : "Sources") + targetName.value
        try targetPath.mkpath()
        
        let initialFile = targetPath + Path(targetName.value + ".swift")
        try initialFile.write("//\n// \(targetName.value).swift\n// \(package.name)\n//\n")
        
        package.addTarget(
            name: targetName.value,
            type: testTarget ? .test : .regular,
            dependencies: dependencies.value?.commaSeparated() ?? []
        )
        try package.sync()
    }
    
}

private class TargetRemoveCommand: IceObject, Command {
    
    let name = "remove"
    let shortDescription = "Remove the given target"
    
    let target = Parameter(completion: .function(.listTargets))
    
    func execute() throws {
        var project = try loadPackage()
        try project.removeTarget(named: target.value)
        try project.sync()
    }
    
}
