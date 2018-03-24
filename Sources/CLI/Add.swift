//
//  Add.swift
//  Ice
//
//  Created by Jake Heiser on 7/21/17.
//

import SwiftCLI
import Core
import Foundation

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
        
        verboseLog("Resolving url: \(ref.url)")
        
        let dependencyVersion: Version
        if let versionValue = version.value {
            guard let specifiedVersion = Version(versionValue) else {
                throw IceError(message: "invalid version")
            }
            dependencyVersion = specifiedVersion
        } else {
            let latestVersion = try ref.latestVersion()
            func manualVersion() -> Version {
                let major = Input.readInt(prompt: "Major version: ")
                let minor = Input.readInt(prompt: "Minor version: ")
                return Version(major, minor, 0)
            }
            dependencyVersion = latestVersion ?? manualVersion()
        }
        
        verboseLog("Resolving at version: \(dependencyVersion)")
        
        var package = try Package.load(directory: ".")
        package.addDependency(ref: ref, version: dependencyVersion)
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
                .flatMap({ ids.index(of: $0) })
                .map({ package.targets[ids.distance(from: ids.startIndex, to: $0)] })
            try targets.forEach { try package.depend(target: $0.name, on: ref.name) }
        }
        try package.write()
    }
    
}
