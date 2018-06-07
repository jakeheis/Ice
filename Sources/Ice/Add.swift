//
//  Add.swift
//  Ice
//
//  Created by Jake Heiser on 7/21/17.
//

import Foundation
import IceKit
import SwiftCLI

class AddCommand: Command {
    
    let name = "add"
    let shortDescription = "Adds the given package"
    
    let dependency = Parameter()
    let version = OptionalParameter()
    
    let targets = Key<String>("-t", "--targets", description: "List of targets which should depend on this dependency")
    let noInteractive = Flag("-n", "--no-interactive", description: "Do not prompt for targets if none are supplied")
    
    func execute() throws {
        guard let ref = RepositoryReference(dependency.value) else {
            throw IceError(message: "not a valid package reference")
        }
        
        verboseOut <<< "Resolving url: \(ref.url)"
        
        let requirement: Package.Dependency.Requirement
        if let versionValue = version.value {
            guard Package.Dependency.Requirement.validate(versionValue) else {
                throw IceError(message: "invalid requirement")
            }
            requirement = .create(from: versionValue)
        } else if let latestVersion = try ref.latestVersion() {
            requirement = .init(version: latestVersion)
        } else {
            stdout <<< "Warning:".yellow.bold + " no tagged versions found"
            requirement = .read()
        }
        
        verboseOut <<< "Resolving at version: \(requirement)"
        
        var package = try Package.load()
        
        verboseOut <<< "Loaded package: \(package.name)"
        
        package.addDependency(ref: ref, requirement: requirement)
        if let targetString = targets.value {
            let targets = targetString.components(separatedBy: ",")
            try targets.forEach { try package.depend(target: $0, on: ref.name) }
        } else if package.targets.count == 1 {
            try package.depend(target: package.targets[0].name, on: ref.name)
        } else if !noInteractive.value {
            stdout <<< ""
            stdout <<< "Which targets depend on this dependency?"
            stdout <<< ""
            let ids = "123456789abcdefghijklmnopqrstuvwxyz".prefix(package.targets.count)
            for (index, target) in package.targets.enumerated() {
                stdout <<< "  " + String(ids[ids.index(ids.startIndex, offsetBy: index)]) + "  " + target.name
            }
            stdout <<< ""
            let targetString = Input.readLine(prompt: "> ", validation: { (input) -> Bool in
                let allowed = CharacterSet(charactersIn: ids + ", ")
                return input.rangeOfCharacter(from: allowed.inverted) == nil
            })
            let targets = targetString
                .compactMap({ ids.index(of: $0) })
                .map({ package.targets[ids.distance(from: ids.startIndex, to: $0)] })
            try targets.forEach { try package.depend(target: $0.name, on: ref.name) }
        }
        try package.write()
    }
    
}
