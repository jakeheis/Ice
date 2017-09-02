//
//  Config.swift
//  CLI
//
//  Created by Jake Heiser on 9/1/17.
//

import Foundation
import SwiftCLI
import Core

class ConfigCommand: Command {
    
    let name = "config"
    
    let action = Parameter()
    let key = OptionalParameter()
    let value = OptionalParameter()
    
    func execute() throws {
        if action.value == "list" {
            let list = Config.layer(config: Config.globalConfig, onto: Config.defaultConfig)
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            guard let data = try? encoder.encode(list),
                let str = String(data: data, encoding: .utf8) else {
                throw IceError(message: "couldn't retrieve config")
            }
            
            print(str)
        } else if action.value == "get" {
            guard let key = key.value else {
                throw IceError(message: "must follow get with the key to get")
            }
            
            let value: Any
            switch key {
            case "bin": value = Config.get(\.bin)
            case "strict": value = Config.get(\.strict)
            default: throw IceError(message: "key \(key) not recognized")
            }
            print(value)
        } else if action.value == "set" {
            guard let key = key.value, let value = value.value else {
                throw IceError(message: "must follow set with the key and value to set")
            }
            
            switch key {
            case "bin": try Config.set(\ConfigFile.bin, value: value)
            case "strict": try Config.set(\ConfigFile.strict, value: (value.lowercased() == "true"))
            default: throw IceError(message: "key \(key) not recognized")
            }
        } else {
            throw IceError(message: "unrecognized action, must be: list | get | set")
        }
    }
    
}
