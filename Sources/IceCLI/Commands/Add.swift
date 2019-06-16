//
//  Add.swift
//  Ice
//
//  Created by Jake Heiser on 7/21/17.
//

import Foundation
import IceKit
import SwiftCLI

class AddCommand: IceObject, Command {
    
    let name = "add"
    let shortDescription = "Adds the given package as a dependency"
    
    let dependency = Parameter(completion: .function(.listRegistry))
    
    let targets = Key<String>("-t", "--targets", description: "List of targets which should depend on this dependency")
    let noInteractive = Flag("-n", "--no-interactive", description: "Do not prompt for targets if none are supplied")
    
    let from = Key<Version>("-f", "--from", description: "The minimum version of the dependency to depend on; allows more recent versions")
    let exact = Key<Version>("-e", "--exact", description: "The exact version of the dependency to depend on")
    let branch = Key<String>("-b", "--branch", description: "The branch of the dependency to depend on")
    let sha = Key<String>("-s", "--sha", description: "The commit hash of the dependency to depend on")
    let local = Flag("-l", "--local", description: "Add this dependency as a local dependency")
    
    var optionGroups: [OptionGroup] {
        return [.atMostOne(from, exact, branch, sha, local)]
    }
    
    func execute() throws {
        guard let ref = RepositoryReference(blob: dependency.value, registry: registry) else {
            throw IceError(message: "not a valid package reference")
        }
        
        Logger.verbose <<< "Resolving url: \(ref.url)"
        
        let requirement: Package.Dependency.Requirement
        if let version = from.value {
            requirement = .init(from: version)
        } else if let exact = exact.value {
            requirement = .exact(exact.string)
        } else if let branch = branch.value {
            requirement = .branch(branch)
        } else if let sha = sha.value {
            requirement = .revision(sha)
        } else if local.value {
            requirement = .localPackage
        } else if let latestVersion = try ref.latestVersion() {
            requirement = .init(from: latestVersion)
        } else {
            throw IceError(message: "no tagged versions found; manually specify version with --from, --exact, --branch, or --sha")
        }
        
        Logger.verbose <<< "Resolving at version: \(requirement)"
        
        var package = try loadPackage()
        
        if package.dependencies.contains(where: { $0.url == ref.url }) {
            throw IceError(message: "package already depends on \(ref.url)")
        }
        
        Logger.verbose <<< "Loaded package: \(package.name)"
        
        let newDependency = package.addDependency(url: ref.url, requirement: requirement)
        try package.sync()
        
        try SPM().resolve()
        
        let libs = package.retrieveLibraries(ofDependency: newDependency)
        if libs.count > 1 {
            stdout <<< ""
            stdout <<< "Note: ".bold.blue + "this dependency offers multiple libraries (" + libs.joined(separator: ", ") + ")"
        }
        
        for lib in libs {
            if let targetString = targets.value {
                for targetName in targetString.commaSeparated() {
                    guard let target = package.getTarget(named: targetName) else {
                        throw IceError(message: "target '\(targetName)' not found")
                    }
                    try package.addTargetDependency(for: target, on: .byName(lib))
                }
            } else if package.targets.count == 1 {
                try package.addTargetDependency(for: package.targets[0], on: .byName(lib))
            } else if !noInteractive.value {
                stdout <<< ""
                stdout <<< "Which targets depend on \(lib)?"
                stdout <<< ""
                
                let possibleTargets = package.targets.filter({ $0.type != .system })
                
                let ids = "123456789abcdefghijklmnopqrstuvwxyz".prefix(possibleTargets.count)
                for (index, target) in possibleTargets.enumerated() {
                    stdout <<< "  " + String(ids[ids.index(ids.startIndex, offsetBy: index)]) + "  " + target.name
                }
                stdout <<< ""
                
                func isTarget(_ input: String) -> Bool {
                    let allowed = CharacterSet(charactersIn: ids + ", ")
                    return input.rangeOfCharacter(from: allowed.inverted) == nil
                }
                let targetString = Input.readLine(prompt: "> ", validation: [
                    .custom("must be a letter or number corresponding to a target", isTarget)
                ])
                
                let distances = targetString.compactMap { ids.ice_firstIndex(of: $0) }
                let targets = distances.map { possibleTargets[ids.distance(from: ids.startIndex, to: $0)] }
                try targets.forEach {
                    try package.addTargetDependency(for: $0, on: .byName(lib))
                }
            }
        }
        
        try package.sync()
    }
    
}
