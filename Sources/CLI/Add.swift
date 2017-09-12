//
//  Add.swift
//  Ice
//
//  Created by Jake Heiser on 7/21/17.
//

import Foundation
import SwiftCLI
import Core

class AddCommand: Command {
    
    let name = "add"
    let shortDescription = "Adds the given package"
    
    let dependency = Parameter()
    let version = OptionalParameter()

    let modules = Key<String>("-m", "--modules", description: "List of modules which should depend on this dependency")
    
    func execute() throws {
        guard let ref = RepositoryReference(dependency.value) else {
            throw IceError(message: "not a valid package reference")
        }
        
        let version = try ref.latestVersion()
        var package = try Package.load(directory: ".")
        
        func manualVersion() -> Version {
            let major = Input.awaitInt(message: "Major version: ")
            let minor = Input.awaitInt(message: "Minor version: ")
            return Version(major, minor, 0)
        }
        let actualVersion = version ?? manualVersion()
        
        package.addDependency(ref: ref, version: actualVersion)
        if let modulesString = modules.value {
            let modules = modulesString.components(separatedBy: ",")
            try modules.forEach { try package.depend(target: $0, on: ref.name) }
        }
        try package.write()
    }
    
}
