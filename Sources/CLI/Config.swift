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
        case "strict": value = Ice.config.get(\.strict)
        default: throw IceError(message: "config key '\(key)' not recognized")
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
        case "strict": try Ice.config.set(\.strict, value: (value.value.lowercased() == "true" || value.value.lowercased() == "yes"))
        default: throw IceError(message: "config key '\(key)' not recognized")
        }
    }
}
