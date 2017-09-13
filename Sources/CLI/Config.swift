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
        let list = Config.layer(config: Config.globalConfig, onto: Config.defaultConfig)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(list),
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
        case "bin": value = Config.get(\.bin)
        case "strict": value = Config.get(\.strict)
        default: throw IceError(message: "key \(key) not recognized")
        }
        print(value)
    }
}

class SetConfigCommand: Command {
    let name = "set"
    let shortDescription = "Sets the config for the given key"
    
    let key = Parameter()
    let value = Parameter()
    
    func execute() throws {
        switch key.value {
        case "bin": try Config.set(\ConfigFile.bin, value: key.value)
        case "strict": try Config.set(\ConfigFile.strict, value: (key.value.lowercased() == "true"))
        default: throw IceError(message: "key \(key) not recognized")
        }
    }
}
