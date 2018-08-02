//
//  File.swift
//  Ice
//
//  Created by Jake Heiser on 9/25/17.
//

import IceKit
import SwiftCLI

class UpdateCommand: IceObject, Command {
    
    let name = "update"
    let shortDescription = "Update package dependencies"
    
    let dependency = OptionalParameter()
    
    let version = Key<Version>("--version", description: "The new version of the dependency to depend on")
    let branch = Key<String>("--branch", description: "The new branch of the dependency to depend on")
    let sha = Key<String>("--sha", description: "The new commit hash of the dependency to depend on")
    
    var optionGroups: [OptionGroup] {
        return [.atMostOne(version, branch, sha)]
    }
    
    func execute() throws {
        guard let dependency = dependency.value else {
            guard version.value == nil && branch.value == nil && sha.value == nil else {
                throw IceError(message: "--version, --branch, and --sha can only be used when updating a specific dependency")
            }
            try SPM().update()
            return
        }
        
        var package = try loadPackage()
        guard let dep = package.dependencies.first(where: { RepositoryReference(url: $0.url).name == dependency }) else {
            throw IceError(message: "No dependency found with that name")
        }
        
        let requirement: Package.Dependency.Requirement
        if let version = version.value {
            requirement = .init(version: version)
        } else if let branch = branch.value {
            requirement = .init(type: .branch, lowerBound: nil, upperBound: nil, identifier: branch)
        } else if let sha = sha.value {
            requirement = .init(type: .revision, lowerBound: nil, upperBound: nil, identifier: sha)
        } else {
            requirement = try inputVersion(for: dep)
        }
        
        try package.updateDependency(dependency: dep, to: requirement)
        
        try package.sync()
    }
    
    private func inputVersion(for dep: Package.Dependency) throws -> Package.Dependency.Requirement {
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
        
        let chosen: Version = Input.readObject(prompt: ">", errorResponse: { (_) in
            self.stdout <<< "Version must be of the form 'major.minor.patch'"
        })
        stdout <<< ""
        
        return .init(version: chosen)
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
