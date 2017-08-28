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
    let dependency = Parameter()
    let version = OptionalParameter()

    let test = Flag("-T", "--test-dependency")
    let global = GlobalOption.global
    let modules = Key<String>("-m", "--modules")
    
    var optionGroups: [OptionGroup] {
        return [
            OptionGroup(options: [test, global], restriction: .atMostOne),
            OptionGroup(options: [modules, global], restriction: .atMostOne)
        ]
    }
    
    func execute() throws {
        guard let ref = RepositoryReference(dependency.value) else {
            throw SwiftProcess.Error.processFailed
        }
        
        let version = Remote.latestVersion(of: ref)
        if global.value {
            try Global.add(ref: ref, version: version)
        } else {
            func manualVersion() -> Version {
                let major = Input.awaitInt(message: "Major version: ")
                let minor = Input.awaitInt(message: "Minor version: ")
                return Version(major, minor, 0)
            }
            let actualVersion = version ?? manualVersion()
            
            var package = try Package.load(directory: ".")
            package.addDependency(ref: ref, version: actualVersion)
            if let modulesString = modules.value {
                let modules = modulesString.components(separatedBy: ",")
                try modules.forEach { try package.depend(target: $0, on: ref.name) }
            }
            try package.write()
        }
    }
    
}
