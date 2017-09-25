//
//  Config.swift
//  CLI
//
//  Created by Jake Heiser on 9/1/17.
//

import Foundation
import SwiftCLI
import Core

class ConfigGroup: CommandGroup {
    let name = "config"
    let shortDescription = "Ice global config commands"
    let children: [Routable] = [
        ListConfigCommand(),
        GetConfigCommand(),
        SetConfigCommand()
    ]
}

private let unrecognizedKeyError = IceError(message: """
unrecognized config key

Valid keys:

  bin           the directory to which Ice should symlink global executables; defaults to /usr/bin/local/bin
  reformat      whether Ice should organize your Package.swift (alphabetize, etc.); defaults to false
""")

class ListConfigCommand: Command {
    let name = "list"
    let shortDescription = "List the current global config"
    func execute() throws {
        let list = ConfigFile.layer(config: Ice.config.globalConfig, onto: ConfigFile.defaultConfig)
        guard let data = try? ConfigFile.encoder.encode(list),
            let str = String(data: data, encoding: .utf8) else {
                throw IceError(message: "couldn't retrieve config")
        }
        
        print(str)
    }
}

class GetConfigCommand: Command {
    let name = "get"
    let shortDescription = "Gets the config for the given key"
    
    let key = Parameter()
    
    func execute() throws {
        let value: Any
        switch key.value {
        case "bin": value = Ice.config.get(\.bin)
        case "reformat": value = Ice.config.get(\.reformat)
        default: throw unrecognizedKeyError
        }
        stdout <<< String(describing: value)
    }
}

class SetConfigCommand: Command {
    let name = "set"
    let shortDescription = "Sets the config for the given key"
    
    let key = Parameter()
    let value = Parameter()
    
    func execute() throws {
        switch key.value {
        case "bin": try Ice.config.set(\.bin, value: value.value)
        case "reformat": try Ice.config.set(\.reformat, value: (value.value.lowercased() == "true" || value.value.lowercased() == "yes"))
        default: throw unrecognizedKeyError
        }
    }
}
