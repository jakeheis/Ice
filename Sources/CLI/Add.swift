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
            OptionGroup(options: [test, global], restriction: .atMostOne)
        ]
    }
    
    func execute() throws {
        let version = Remote.latestVersion(of: dependency.value)
        if global.value {
            try Global.add(name: dependency.value, version: version)
        } else {
            func manualVersion() -> Version {
                let major = Input.awaitInt(message: "Major version: ")
                let minor = Input.awaitInt(message: "Minor version: ")
                return Version(major, minor, 0)
            }
            let actualVersion = version ?? manualVersion()
            
            var package = try Package.load(directory: ".")
            package.addDependency(name: dependency.value, version: actualVersion)
            if let modulesString = modules.value {
                let modules = modulesString.components(separatedBy: ",")
                let depName = dependency.value.components(separatedBy: "/")[1]
                try modules.forEach { try package.depend(target: $0, on: depName) }
            }
            try package.write()
        }
    }
    
}
