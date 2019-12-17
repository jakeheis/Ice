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
    let length = Config.Keys.allCases.reduce(0) { $1.rawValue.count > $0 ? $1.rawValue.count : $0 }
    return Config.Keys.allCases.map {
        let padding = String(repeating: " ", count: length - $0.rawValue.count + 2)
        return "  \($0.rawValue)\(padding)\($0.shortDescription)"
    }.joined(separator: "\n")
}()
private let unrecognizedKeyError = IceError(message: """
unrecognized config key

Valid keys:

\(allKeys)
""")
private let configCompletions = Config.Keys.allCases.map { ($0.rawValue, "") }

class ShowConfigCommand: IceObject, Command {
    
    let name = "show"
    let shortDescription = "Show the current Ice configuration"
    
    func execute() throws {
        let keyCol = TextTableColumn(header: "Key")
        let localCol = TextTableColumn(header: "Local")
        let globalCol = TextTableColumn(header: "Global")
        let resolvedCol = TextTableColumn(header: "Resolved")
        var table = TextTable(columns: [keyCol, localCol, globalCol, resolvedCol])
        
        Config.Keys.allCases.forEach { table.addRow(values: createRow(key: $0)) }
        stdout <<< table.render()
    }
    
    func createRow(key: Config.Keys) -> [String] {
        let local = config.local
        let global = Config(file: config.global) // Fill in defaults if any keys are missing
        let resolved = config.resolved
        
        var row = [key.rawValue]
        switch key {
        case .reformat:
            row += [box(local.reformat), box(global.reformat), box(resolved.reformat)]
        case .openAfterXc:
            row += [box(local.openAfterXc), box(global.openAfterXc), box(resolved.openAfterXc)]
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
    
    @Param(completion: .values(configCompletions))
    var key: String
    
    func execute() throws {
        guard let key = Config.Keys(rawValue: key) else {
            throw unrecognizedKeyError
        }
        let resolved = config.resolved
        let value: Any
        switch key {
        case .reformat: value = resolved.reformat
        case .openAfterXc: value = resolved.openAfterXc
        }
        stdout <<< String(describing: value)
    }
    
}

class SetConfigCommand: IceObject, Command {
    
    let name = "set"
    let shortDescription = "Sets the config for the given key"
    
    @Param(completion: .values(configCompletions))
    var key: String
    
    @Param(completion: .none)
    var value: String
    
    @Flag("-g", "--global", description: "Update the global configuation; default")
    var global: Bool
    
    @Flag("-l", "--local", description: "Update the local configuation")
    var local: Bool
    
    var configScope: ConfigManager.UpdateScope {
        return (local ? .local : .global)
    }
    
    var optionGroups: [OptionGroup] {
        return [.atMostOne($global, $local)]
    }
    
    func execute() throws {
        guard let key = Config.Keys(rawValue: key) else {
            throw unrecognizedKeyError
        }
        switch key {
        case .reformat:
            guard let val = Bool(input: value) else {
                throw IceError(message: "invalid value (must be true/false)")
            }
            try config.update(scope: configScope) { $0.reformat = val }
        case .openAfterXc:
            guard let val = Bool(input: value) else {
                throw IceError(message: "invalid value (must be true/false)")
            }
            try config.update(scope: configScope) { $0.openAfterXc = val }
        }
    }
    
}
