//
//  Registry.swift
//  Core
//
//  Created by Jake Heiser on 9/13/17.
//

import Foundation
import PathKit

public protocol RegistryType {
    func get(_ name: String) -> RegistryEntry?
}

public class Registry: RegistryType {
    
    private static let url = "https://github.com/jakeheis/IceRegistry"
    
    let directory: Path
    private var localPath: Path { return directory + "local.json" }
    private var sharedRepo: Path { return directory + "shared" }
    private var sharedPath: Path { return sharedRepo + "Registry" }
    
    private lazy var localRegistry = {
        return LocalRegistryFile.load(from: localPath) ?? LocalRegistryFile(entries: [], lastRefreshed: nil)
    }()
    
    init(registryPath: Path) {
        self.directory = registryPath
        
        if let lastRefreshed = localRegistry.lastRefreshed {
            // If current date is more than 30 days after last refresh
            if Date() > lastRefreshed.addingTimeInterval(60 * 60 * 24 * 30) {
                do {
                    try refresh(silent: true)
                } catch {}
            }
        } else {
            do {
                try refresh(silent: true)
            } catch {}
        }
    }
    
    public func refresh(silent: Bool = false) throws {
        let timeout = silent ? 4 : nil
        if sharedRepo.exists {
            try Git.pull(path: sharedRepo.string, silent: silent, timeout: timeout)
        } else {
            try Git.clone(url: Registry.url, to: sharedRepo.string, silent: silent, timeout: timeout)
        }
        
        localRegistry.lastRefreshed = Date()
        try write()
    }
    
    public func add(name: String, url: String) throws {
        localRegistry.entries.append(.init(name: name, url: url, description: nil))
        try write()
    }
    
    public func get(_ name: String) -> RegistryEntry? {
        if let matching = localRegistry.entries.first(where: { $0.name == name }) {
            return matching
        }
        
        let letterPath = sharedPath + (String(name.uppercased()[name.startIndex]) + ".json")
        let sharedRegistry = SharedRegistryFile.load(from: letterPath)
        if let matching = sharedRegistry?.entries.first(where: { $0.name == name }) {
            return matching
        }
        
        return nil
    }
    
    public func remove(_ name: String) throws {
        guard let index = localRegistry.entries.index(where: { $0.name == name })  else {
            throw IceError(message: "shortcut does not exist")
        }
        localRegistry.entries.remove(at: index)
        
        try write()
    }
    
    public func search(query: String, includeDescription: Bool) throws -> [RegistryEntry] {
        do {
            try refresh(silent: true)
        } catch {}
        
        var all = Set<String>()

        func filterOnName(entries: [RegistryEntry]) -> [RegistryEntry] {
            return entries.filter { $0.name.lowercased().contains(query.lowercased()) && !all.contains($0.name) }
        }
        
        var localEntries: [RegistryEntry] = filterOnName(entries: localRegistry.entries)
        all.formUnion(localEntries.map { $0.name })
        
        var highEntries: [RegistryEntry] = []
        var middleEntries: [RegistryEntry] = []
        var bottomEntries: [RegistryEntry] = []
        forEachShared { (file, fileName) in
            var results = filterOnName(entries: file.entries)
            let prioritySplit = results.partition(by: { $0.name.lowercased().hasPrefix(query.lowercased()) })
            middleEntries += results.prefix(upTo: prioritySplit)
            highEntries += results.suffix(from: prioritySplit)
            all.formUnion(results.map { $0.name })
        }
        
        if includeDescription {
            func filterOnDescription(entries: [RegistryEntry]) -> [RegistryEntry] {
                return entries.filter { $0.description?.lowercased().contains(query.lowercased()) ?? false  && !all.contains($0.name)}
            }
            localEntries += filterOnDescription(entries: localRegistry.entries)
            all.formUnion(localEntries.map { $0.name })
            forEachShared { (file, _) in
                var results = filterOnDescription(entries: file.entries)
                let startChar = String(query.lowercased().prefix(upTo: query.index(after: query.startIndex)))
                let prioritySplit = results.partition(by: { $0.name.lowercased().hasPrefix(startChar) })
                bottomEntries += results.prefix(upTo: prioritySplit)
                middleEntries += results.suffix(from: prioritySplit)
            }
        }
        
        var combined = localEntries + highEntries + middleEntries + bottomEntries
        if let index = combined.index(where: { $0.name.lowercased() == query.lowercased() } ) {
            let perfectMatch = combined.remove(at: index)
            combined.insert(perfectMatch, at: 0)
        }
        
        return combined
    }
    
    private func forEachShared(block: (_ file: SharedRegistryFile, _ fileName: String) -> ()) {
        let paths = (try? sharedPath.children()) ?? []
        paths.forEach { (path) in
            if let file = SharedRegistryFile.load(from: path) {
                block(file, path.lastComponentWithoutExtension)
            }
        }
    }
    
    func write() throws {
        try localPath.write(JSON.encoder.encode(localRegistry))
    }
    
}

public struct RegistryEntry: Codable {
    public let name: String
    public let url: String
    public let description: String?
}

private struct LocalRegistryFile: Codable {
    
    var entries: [RegistryEntry]
    var lastRefreshed: Date?
    
    static func load(from path: Path) -> LocalRegistryFile? {
        guard let data = try? path.read(),
            let file = try? JSONDecoder().decode(LocalRegistryFile.self, from: data) else {
                return nil
        }
        return file
    }
    
}

private struct SharedRegistryFile: Codable {
    
    var entries: [RegistryEntry]
    
    static func load(from path: Path) -> SharedRegistryFile? {
        guard let data = try? path.read(),
            let file = try? JSONDecoder().decode(SharedRegistryFile.self, from: data) else {
                return nil
        }
        return file
    }
    
}
