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
    
    @Param(completion: .none)
    var targetName: String

    @Flag("-t", "--test", description: "Marks this target as a test target")
    var isTest: Bool
    
    @Flag("-s", "--system", description: "Marks this target as a system target")
    var isSystem: Bool
    
    @Key("-d", "--dependencies", description: "Creates the new target with the given dependencies; comma-separated")
    var dependencies: String?
    
    var optionGroups: [OptionGroup] {
        return [.atMostOne($isTest, $isSystem), .atMostOne($isSystem, $dependencies)]
    }
    
    func execute() throws {
        var package = try loadPackage()
        
        if package.targets.contains(where: { $0.name == targetName }) {
            throw IceError(message: "target \(targetName) already exists")
        }
        
        var targetType: Package.Target.TargetType
        if isTest {
            targetType = .test
        } else if isSystem {
            targetType = .system
        } else {
            targetType = .regular
            if targetName.contains("Test") {
                stdout <<< ""
                stdout <<< "Warning: ".yellow.bold + "Target name contains the word `Tests` but --test was not passed."
                stdout <<< ""
                stdout <<< "Is this target a test target? [y/N]"
                targetType = Input.readBool(prompt: "> ") ? .test : .regular
            }
        }
        
        let targetDependencies = dependencies?.commaSeparated().map { Package.Target.Dependency.byName($0) } ?? []
        package.addTarget(
            name: targetName,
            type: targetType,
            dependencies: targetDependencies
        )
        try package.sync()
        
        let targetPath = Path.current + (targetType == .test ? "Tests" : "Sources") + targetName
        try targetPath.mkpath()
        
        switch targetType {
        case .regular, .test:
            let initialFile = targetPath + Path(targetName + ".swift")
            try initialFile.write("""
            //
            //  \(targetName).swift
            //  \(package.name)
            //

            """)
        case .system:
            let initialFile = targetPath + "module.modulemap"
            try initialFile.write("""
            module \(targetName) [system] {
              header "/usr/include/\(targetName).h"
              link "\(targetName)"
              export *
            }
            
            """)
        }
    }
    
}

private class TargetRemoveCommand: IceObject, Command {
    
    let name = "remove"
    let shortDescription = "Remove the given target"
    
    @Param(completion: .function(.listTargets))
    var target: String
    
    func execute() throws {
        var package = try loadPackage()
        guard let target = package.getTarget(named: target) else {
            throw IceError(message: "target '\(self.target)' not found")
        }
        package.removeTarget(target)
        try package.sync()
    }
    
}
