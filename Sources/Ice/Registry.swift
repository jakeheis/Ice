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
    
    let ref = Parameter()
    let shortName = Parameter()

    func execute() throws {
        guard let ref = RepositoryReference(blob: ref.value, registry: registry) else {
            throw IceError(message: "invalid repository reference")
        }
        
        try registry.add(name: shortName.value, url: ref.url)
    }
    
}

private class RemoveEntryCommand: IceObject, Command {
    
    let name = "remove"
    let shortDescription = "Remove the given entry from your local registry"
    
    let from = Parameter()
    
    func execute() throws {
        try registry.remove(from.value)
    }
    
}

private class LookupEntryCommand: IceObject, Command {
    
    let name = "lookup"
    let shortDescription = "Lookup an entry in the registry"
    
    let from = Parameter()
    
    func execute() throws {
        guard let value = registry.get(from.value) else {
            throw IceError(message: "couldn't find \(from.value)")
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
