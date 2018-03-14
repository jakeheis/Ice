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
        guard let key = ConfigFile.Keys(rawValue: key.value) else {
            throw unrecognizedKeyError
        }
        let value: Any
        switch key {
        case .bin:
            value = Ice.config.get(\.bin)
        case .reformat:
            value = Ice.config.get(\.reformat)
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
        guard let key = ConfigFile.Keys(rawValue: key.value) else {
            throw unrecognizedKeyError
        }
        switch key {
        case .bin:
            try Ice.config.set(\.bin, value: value.value)
        case .reformat:
            let val: Bool
            switch value.value.lowercased() {
            case "true", "t", "yes", "y":
                val = true
            case "false", "f", "no", "n":
                val = false
            default:
                throw IceError(message: "invalid value (must be true/false)")
            }
            try Ice.config.set(\.reformat, value: val)
        }
    }
}
