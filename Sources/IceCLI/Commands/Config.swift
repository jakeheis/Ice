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

private let allKeys: String = {
    let length = Config.Keys.all.reduce(0) { $1.rawValue.count > $0 ? $1.rawValue.count : $0 }
    return Config.Keys.all.map {
        let padding = String(repeating: " ", count: length - $0.rawValue.count + 2)
        return "  \($0.rawValue)\(padding)\($0.shortDescription)"
    }.joined(separator: "\n")
}()
private let unrecognizedKeyError = IceError(message: """
unrecognized config key

Valid keys:

\(allKeys)
""")
private let configCompletions = Config.Keys.all.map { ($0.rawValue, "") }

class ShowConfigCommand: IceObject, Command {
    
    let name = "show"
    let shortDescription = "Show the current Ice configuration"
    
    func execute() throws {
        let keyCol = TextTableColumn(header: "Key")
        let localCol = TextTableColumn(header: "Local")
        let globalCol = TextTableColumn(header: "Global")
        let resolvedCol = TextTableColumn(header: "Resolved")
        var table = TextTable(columns: [keyCol, localCol, globalCol, resolvedCol])
        
        Config.Keys.all.forEach { table.addRow(values: createRow(key: $0)) }
        stdout <<< table.render()
    }
    
    func createRow(key: Config.Keys) -> [String] {
        var row = [key.rawValue]
        switch key {
        case .reformat:
            row += [box(config.local.reformat), box(config.global.reformat), box(config.reformat)]
        case .openAfterXc:
            row += [box(config.local.openAfterXc), box(config.global.openAfterXc), box(config.openAfterXc)]
        }
        return row
    }
    
    func box<T>(_ item: T?) -> String {
        if let item = item {
            return String(describing: item)
        }
        return "(none)"
    }
    
}

class GetConfigCommand: IceObject, Command {
    
    let name = "get"
    let shortDescription = "Gets the config for the given key"
    
    let key = Parameter(completion: .values(configCompletions))
    
    func execute() throws {
        guard let key = Config.Keys(rawValue: key.value) else {
            throw unrecognizedKeyError
        }
        let value: Any
        switch key {
        case .reformat: value = config.reformat
        case .openAfterXc: value = config.openAfterXc
        }
        stdout <<< String(describing: value)
    }
    
}

class SetConfigCommand: IceObject, Command {
    
    let name = "set"
    let shortDescription = "Sets the config for the given key"
    
    let key = Parameter(completion: .values(configCompletions))
    let value = Parameter(completion: .none)
    
    let global = Flag("-g", "--global", description: "Update the global configuation; default")
    let local = Flag("-l", "--local", description: "Update the local configuation")
    
    var configScope: Config.UpdateScope {
        return (local.value ? .local : .global)
    }
    
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
            try config.update(scope: configScope) { $0.reformat = val }
        case .openAfterXc:
            guard let val = Bool.convert(from: value.value) else {
                throw IceError(message: "invalid value (must be true/false)")
            }
            try config.update(scope: configScope) { $0.openAfterXc = val }
        }
    }
    
}
