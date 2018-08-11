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
    let isSystem = Flag("-s", "--system", description: "Marks this target as a system target")
    let dependencies = Key<String>("-d", "--dependencies", description: "Creates the new target with the given dependencies; comma-separated")
    
    var optionGroups: [OptionGroup] {
        return [.atMostOne(isTest, isSystem), .atMostOne(isSystem, dependencies)]
    }
    
    func execute() throws {
        var package = try loadPackage()
        
        if package.targets.contains(where: { $0.name == targetName.value }) {
            throw IceError(message: "target \(targetName.value) already exists")
        }
        
        var targetType: Package.Target.TargetType
        if isTest.value {
            targetType = .test
        } else if isSystem.value {
            targetType = .system
        } else {
            targetType = .regular
            if targetName.value.contains("Test") {
                stdout <<< ""
                stdout <<< "Warning: ".yellow.bold + "Target name contains the word `Tests` but --test was not passed."
                stdout <<< ""
                stdout <<< "Is this target a test target? [y/N]"
                targetType = Input.readBool(prompt: "> ") ? .test : .regular
            }
        }
        
        package.addTarget(
            name: targetName.value,
            type: targetType,
            dependencies: dependencies.value?.commaSeparated() ?? []
        )
        try package.sync()
        
        let targetPath = Path.current + (targetType == .test ? "Tests" : "Sources") + targetName.value
        try targetPath.mkpath()
        
        switch targetType {
        case .regular, .test:
            let initialFile = targetPath + Path(targetName.value + ".swift")
            try initialFile.write("""
            //
            //  \(targetName.value).swift
            //  \(package.name)
            //

            """)
        case .system:
            let initialFile = targetPath + "module.modulemap"
            try initialFile.write("""
            module \(targetName.value) [system] {
              header "/usr/include/\(targetName.value).h"
              link "\(targetName.value)"
              export *
            }
            
            """)
        }
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
