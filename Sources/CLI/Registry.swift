//
//  Registry.swift
//  CLI
//
//  Created by Jake Heiser on 9/13/17.
//

import SwiftCLI
import Core

class RegistryGroup: CommandGroup {
    let name = "registry"
    let shortDescription = "Manage local package registry"
    let children: [Routable] = [AddEntryCommand(), RemoveEntryCommand(), LookupEntryCommand()]
}

private class AddEntryCommand: Command {
    
    let name = "add"
    
    let ref = Parameter()
    let shortName = Parameter()

    func execute() throws {
        guard let ref = RepositoryReference(ref.value) else {
            throw IceError(message: "invalid repository reference")
        }
        
        try Registry.add(name: shortName.value, url: ref.url)
    }
    
}

private class RemoveEntryCommand: Command {
    
    let name = "remove"
    
    let from = Parameter()
    
    func execute() throws {
        try Registry.remove(from.value)
    }
    
}

private class LookupEntryCommand: Command {
    
    let name = "lookup"
    
    let from = Parameter()
    
    func execute() throws {
        guard let value = Registry.get(from.value) else {
            throw IceError(message: "couldn't find \(from.value)")
        }
        print(value)
    }
    
}
