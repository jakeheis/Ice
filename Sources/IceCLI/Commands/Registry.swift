//
//  Registry.swift
//  Ice
//
//  Created by Jake Heiser on 9/13/17.
//

import IceKit
import SwiftCLI

class RegistryGroup: IceObject, CommandGroup {
    let name = "registry"
    let shortDescription = "Manage local package registry"
    lazy var children: [Routable] = [
        AddEntryCommand(ice: ice),
        RemoveEntryCommand(ice: ice),
        LookupEntryCommand(ice: ice),
        RefreshCommand(ice: ice)
    ]
}

private class AddEntryCommand: IceObject, Command {
    
    let name = "add"
    let shortDescription = "Add the given entry to your local registry"
    
    @Param(completion: .none)
    var ref: String
    
    @Param(completion: .none)
    var shortName: String

    func execute() throws {
        guard let ref = RepositoryReference(blob: ref, registry: registry) else {
            throw IceError(message: "invalid repository reference")
        }
        
        try registry.add(name: shortName, url: ref.url)
    }
    
}

private class RemoveEntryCommand: IceObject, Command {
    
    let name = "remove"
    let shortDescription = "Remove the given entry from your local registry"
    
    @Param(completion: .none)
    var entry: String
    
    func execute() throws {
        try registry.remove(entry)
    }
    
}

private class LookupEntryCommand: IceObject, Command {
    
    let name = "lookup"
    let shortDescription = "Lookup an entry in the registry"
    
    @Param(completion: .function(.listRegistry))
    var entry: String
    
    func execute() throws {
        guard let value = registry.get(entry) else {
            throw IceError(message: "couldn't find \(entry)")
        }
        stdout <<< value.url
    }
    
}

private class RefreshCommand: IceObject, Command {
    
    let name = "refresh"
    let shortDescription = "Refresh the global registry"
    
    func execute() throws {
        try registry.refresh()
    }
    
}
