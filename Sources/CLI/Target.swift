//
//  Target.swift
//  Ice
//
//  Created by Jake Heiser on 7/22/17.
//

import SwiftCLI
import Core
import FileKit

class TargetCommand: Command {
    
    let name = "target"
    let shortDescription = "Creates a new target"
    
    let targetName = Parameter()

    let isTest = Flag("-t", "--test")
    let dependencies = Key<String>("-d", "--depends-on")
    
    func execute() throws {
        var package = try Package.load(directory: ".")
        
        if package.targets.contains(where: { $0.name == targetName.value }) {
            throw IceError(message: "target \(targetName.value) already exists")
        }
        
        var testTarget = isTest.value
        if !testTarget && targetName.value.contains("Test") {
            testTarget = Input.awaitYesNoInput(
                message: "Warning: Target name contains the word `Tests` but --test was not passed.\n\nIs this target a test target? "
            )
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
