//
//  Registry.swift
//  Core
//
//  Created by Jake Heiser on 9/13/17.
//

import Foundation
import FileKit

public class Registry {
    
    private static let url = "https://github.com/jakeheis/IceRegistry"
    private static let directory = Global.root + "Registry"
    private static let localPath = directory + "local.json"
    private static let sharedPath = directory + "shared"
    
    private static var localRegistry = RegistryFile.load(from: localPath)
    
    private static func setup() throws {
        try Global.setup()
        try directory.createDirectory(withIntermediateDirectories: true)
    }
    
    public static func refresh() throws {
        try setup()
        
        if sharedPath.exists {
            try Git.pull(path: sharedPath.rawValue)
        } else {
            try Git.clone(url: url, to: sharedPath.rawValue, version: nil)
        }
    }
    
    public static func add(name: String, url: String) throws {
        try setup()
        
        var newRegistry: RegistryFile
        if let localRegistry = localRegistry {
            newRegistry = localRegistry
        } else {
            newRegistry = RegistryFile(entries: [])
        }
        newRegistry.entries.append(.init(name: name, url: url))
        
        self.localRegistry = newRegistry
        try JSONEncoder().encode(newRegistry).write(to: localPath)
    }
    
    public static func get(_ name: String) -> String? {
        if let matching = localRegistry?.entries.first(where: { $0.name == name }) {
            return matching.url
        }
        
        let letterPath = sharedPath + "Registry" + (String(name.uppercased()[name.startIndex]) + ".json")
        let sharedRegistry = RegistryFile.load(from: letterPath)
        if let matching = sharedRegistry?.entries.first(where: { $0.name == name }) {
            return matching.url
        }
        
        return nil
    }
    
    public static func remove(_ name: String) throws {
        guard var localRegistry = localRegistry else {
            throw IceError(message: "no registry file found")
        }
        guard let index = localRegistry.entries.index(where: { $0.name == name })  else {
            throw IceError(message: "shortcut does not exist")
        }
        localRegistry.entries.remove(at: index)
        
        self.localRegistry = localRegistry
        try JSONEncoder().encode(localRegistry).write(to: localPath)
    }
    
}

private struct RegistryFile: Codable {
    
    public struct Entry: Codable {
        let name: String
        let url: String
    }
    
    public var entries: [Entry]
    
    static func load(from path: Path) -> RegistryFile? {
        guard let data = try? Data.read(from: path),
            let file = try? JSONDecoder().decode(RegistryFile.self, from: data) else {
                return nil
        }
        return file
    }
    
}
