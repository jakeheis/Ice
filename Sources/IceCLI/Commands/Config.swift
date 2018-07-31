//
//  Config.swift
//  CLI
//
//  Created by Jake Heiser on 9/1/17.
//

import Foundation
import IceKit
import SwiftCLI
import SwiftyTextTable

class ConfigGroup: IceObject, CommandGroup {
    let name = "config"
    let shortDescription = "Ice global config commands"
    lazy var children: [Routable] = [
        ShowConfigCommand(ice: ice),
        GetConfigCommand(ice: ice),
        SetConfigCommand(ice: ice)
    ]
}

private let unrecognizedKeyError = IceError(message: """
unrecognized config key

Valid keys:

  reformat      whether Ice should organize your Package.swift (alphabetize, etc.); defaults to false
""")

class ShowConfigCommand: IceObject, Command {
    
    let name = "show"
    let shortDescription = "Show the current Ice configuration"
    
    func execute() throws {
        let keyCol = TextTableColumn(header: "Key")
        let localCol = TextTableColumn(header: "Local")
        let globalCol = TextTableColumn(header: "Global")
        let resolvedCol = TextTableColumn(header: "Resolved")
        var table = TextTable(columns: [keyCol, localCol, globalCol, resolvedCol])
        
        table.addRow(values: row(key: .reformat, value: { $0.reformat?.description }))
        stdout <<< table.render()
    }
    
    func row(key: Config.Keys, value dig: (Config.File) -> String?) -> [String] {
        var values: [String] = [key.rawValue]
        
        if let value = dig(config.local) {
            values.append(value)
        } else {
            values.append("(none)")
        }
        if let value = dig(config.global) {
            values.append(value)
        } else {
            let value = dig(Config.defaultConfig)!
            values.append(value)
        }
        values.append(config.get(key))
        
        return values
    }
    
    private func printConfig(heading: String, file: Config.File?) {
        guard let file = file else {
            return
        }
        var lines: [String] = []
        if let reformat = file.reformat {
            lines.append("  reformat: " + reformat.description)
        }
        if lines.isEmpty {
            return
        }
        stdout <<< heading
        stdout <<< lines.joined(separator: "\n")
    }
    
}

class GetConfigCommand: IceObject, Command {
    
    let name = "get"
    let shortDescription = "Gets the config for the given key"
    
    let key = Parameter()
    
    func execute() throws {
        guard let key = Config.Keys(rawValue: key.value) else {
            throw unrecognizedKeyError
        }
        stdout <<< config.get(key)
    }
    
}

class SetConfigCommand: IceObject, Command {
    
    let name = "set"
    let shortDescription = "Sets the config for the given key"
    
    let key = Parameter()
    let value = Parameter()
    
    let global = Flag("-g", "--global", description: "Update the global configuation; default")
    let local = Flag("-l", "--local", description: "Update the local configuation")
    
    var optionGroups: [OptionGroup] {
        return [.atMostOne(global, local)]
    }
    
    func execute() throws {
        guard let key = Config.Keys(rawValue: key.value) else {
            throw unrecognizedKeyError
        }
        switch key {
        case .reformat:
            guard let val = Bool.convert(from: value.value) else {
                throw IceError(message: "invalid value (must be true/false)")
            }
            try config.set(\.reformat, value: val, global: !local.value)
        }
    }
    
}
