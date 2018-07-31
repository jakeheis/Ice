//
//  Config.swift
//  CLI
//
//  Created by Jake Heiser on 9/1/17.
//

import Foundation
import IceKit
import SwiftCLI

class ConfigGroup: IceObject, CommandGroup {
    let name = "config"
    let shortDescription = "Ice global config commands"
    lazy var children: [Routable] = [
        ListConfigCommand(ice: ice),
        GetConfigCommand(ice: ice),
        SetConfigCommand(ice: ice)
    ]
}

private let unrecognizedKeyError = IceError(message: """
unrecognized config key

Valid keys:

  reformat      whether Ice should organize your Package.swift (alphabetize, etc.); defaults to false
""")

class ListConfigCommand: IceObject, Command {
    
    let name = "list"
    let shortDescription = "List the current global config"
    
    func execute() throws {
        let list = ConfigFile.layer(config: config.globalConfig, onto: ConfigFile.defaultConfig)
        guard let data = try? ConfigFile.encoder.encode(list),
            let str = String(data: data, encoding: .utf8) else {
                throw IceError(message: "couldn't retrieve config")
        }
        
        print(str)
    }
    
}

class GetConfigCommand: IceObject, Command {
    
    let name = "get"
    let shortDescription = "Gets the config for the given key"
    
    let key = Parameter()
    
    func execute() throws {
        guard let key = ConfigFile.Keys(rawValue: key.value) else {
            throw unrecognizedKeyError
        }
        let value: Any
        switch key {
        case .reformat:
            value = config.get(\.reformat)
        }
        stdout <<< String(describing: value)
    }
    
}

class SetConfigCommand: IceObject, Command {
    
    let name = "set"
    let shortDescription = "Sets the config for the given key"
    
    let key = Parameter()
    let value = Parameter()
    
    func execute() throws {
        guard let key = ConfigFile.Keys(rawValue: key.value) else {
            throw unrecognizedKeyError
        }
        switch key {
        case .reformat:
            guard let val = Bool.convert(from: value.value) else {
                throw IceError(message: "invalid value (must be true/false)")
            }
            try config.set(\.reformat, value: val)
        }
    }
    
}
