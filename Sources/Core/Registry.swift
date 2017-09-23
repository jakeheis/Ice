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
    
    let directory: Path
    private lazy var localPath = directory + "local.json"
    private lazy var sharedRepo = directory + "shared"
    private lazy var sharedPath = sharedRepo + "Registry"
    
    private lazy var localRegistry = RegistryFile.load(from: localPath)
    
    init(registryPath: Path) {
        self.directory = registryPath
    }
    
    public func refresh(silent: Bool = false) throws {
        if sharedRepo.exists {
            try Git.pull(path: sharedRepo.rawValue, silent: silent)
        } else {
            try Git.clone(url: Registry.url, to: sharedRepo.rawValue, version: nil, silent: silent)
        }
    }
    
    public func add(name: String, url: String) throws {
        var newRegistry: RegistryFile
        if let localRegistry = localRegistry {
            newRegistry = localRegistry
        } else {
            newRegistry = RegistryFile(entries: [])
        }
        newRegistry.entries.append(.init(name: name, url: url, description: nil))
        
        self.localRegistry = newRegistry
        try JSONEncoder().encode(newRegistry).write(to: localPath)
    }
    
    public func get(_ name: String) -> RegistryEntry? {
        if let matching = localRegistry?.entries.first(where: { $0.name == name }) {
            return matching
        }
        
        let letterPath = sharedPath + (String(name.uppercased()[name.startIndex]) + ".json")
        let sharedRegistry = RegistryFile.load(from: letterPath)
        if let matching = sharedRegistry?.entries.first(where: { $0.name == name }) {
            return matching
        }
        
        return nil
    }
    
    public func remove(_ name: String) throws {
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
    
    public func search(query: String, includeDescription: Bool) throws -> [RegistryEntry] {
        try refresh(silent: true)
        
        var all = Set<String>()

        func filterOnName(entries: [RegistryEntry]) -> [RegistryEntry] {
            return entries.filter { $0.name.lowercased().contains(query.lowercased()) && !all.contains($0.name) }
        }
        
        var localEntries: [RegistryEntry] = filterOnName(entries: localRegistry?.entries ?? [])
        all.formUnion(localEntries.map { $0.name })
        
        var entries: [RegistryEntry] = []
        forEachShared { (file, fileName) in
            let results = filterOnName(entries: file.entries)
            if fileName == String(query.uppercased()[query.startIndex]) {
                entries = results + entries // Rank results with the starting letter higher
            } else {
                entries += results
            }
            all.formUnion(results.map { $0.name })
        }
        
        if includeDescription {
            func filterOnDescription(entries: [RegistryEntry]) -> [RegistryEntry] {
                return entries.filter { $0.description?.lowercased().contains(query.lowercased()) ?? false  && !all.contains($0.name)}
            }
            localEntries += filterOnDescription(entries: localRegistry?.entries ?? [])
            all.formUnion(localEntries.map { $0.name })
            forEachShared { (file, _) in
                let results = filterOnDescription(entries: file.entries)
                entries += results
            }
        }
        
        return localEntries + entries
    }
    
    private func forEachShared(block: (_ file: RegistryFile, _ fileName: String) -> ()) {
        let paths = sharedPath.children()
        paths.forEach { (path) in
            if let file = RegistryFile.load(from: path) {
                block(file, path.fileName)
            }
        }
    }
    
}

public struct RegistryEntry: Codable {
    public let name: String
    public let url: String
    public let description: String?
}

private struct RegistryFile: Codable {
    
    public var entries: [RegistryEntry]
    
    static func load(from path: Path) -> RegistryFile? {
        guard let data = try? Data.read(from: path),
            let file = try? JSONDecoder().decode(RegistryFile.self, from: data) else {
                return nil
        }
        return file
    }
    
}
