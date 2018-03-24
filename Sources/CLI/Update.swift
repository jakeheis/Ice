//
//  File.swift
//  CLI
//
//  Created by Jake Heiser on 9/25/17.
//

import SwiftCLI
import Core

class UpdateCommand: Command {
    
    let name = "update"
    let shortDescription = "Update package dependencies"
    
    let dependency = OptionalParameter()
    let version = OptionalParameter()
    
    func execute() throws {
        guard let dependency = dependency.value else {
            try SPM().update()
            return
        }
        
        var package = try Package.load(directory: ".")
        guard let dep = package.dependencies.first(where: { RepositoryReference(url: $0.url).name == dependency }) else {
            throw IceError(message: "No dependency found with that name")
        }
        
        let depVersion: Version
        if let argVersion = version.value {
            guard let typedVersion = Version(argVersion) else {
                throw IceError(message: "Invalid version format \"\(argVersion)\"")
            }
            depVersion = typedVersion
        } else {
            depVersion = try inputVersion(for: dep)
        }
        
        try package.updateDependency(dependency: dep, to: depVersion)
        
        try package.write()
    }
    
    private func inputVersion(for dep: Package.Dependency) throws -> Version {
        stdout <<< ""
        let current = currentVersion(of: dep)
        stdout <<< "Current version: ".dim + current
        
        if let versions = try? RepositoryReference(url: dep.url).retrieveVersions().reversed(), !versions.isEmpty {
            stdout <<< ""
            stdout <<< "Suggested versions:".dim
            
            if let current = Version(current) {
                let mostRecentOfSameMinor = versions.first(where: { $0.major == current.major && $0.minor == current.minor })
                if let mostRecentOfSameMinor = mostRecentOfSameMinor, mostRecentOfSameMinor != current {
                    stdout <<< "- " + mostRecentOfSameMinor.description
                }
                let mostRecentOfSameMajor = versions.first(where: { $0.major == current.major })
                if let mostRecentOfSameMajor = mostRecentOfSameMajor, mostRecentOfSameMajor != current, mostRecentOfSameMajor != mostRecentOfSameMinor {
                    stdout <<< "- " + mostRecentOfSameMajor.description
                }
            }
            
            stdout <<< "- " + versions.first!.description
            stdout <<< ""
        }
        
        stdout <<< "Input new version:"
        stdout <<< ""
        let chosen: Version = Input.readObject(prompt: "> ")
        stdout <<< ""
        
        return chosen
    }
    
    private func currentVersion(of dep: Package.Dependency) -> String {
        if let resolved = try? Resolved.load(from: "."), let pin = resolved.findPin(url: dep.url) {
            if let version = pin.state.version {
                return version
            } else if let branch = pin.state.branch {
                return branch
            } else {
                return pin.state.revision
            }
        } else if let lowerBound = dep.requirement.lowerBound {
            return lowerBound
        } else if let id = dep.requirement.identifier {
            return id
        }
        return "(none)"
    }
    
}
