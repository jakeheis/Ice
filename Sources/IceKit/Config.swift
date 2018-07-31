//
//  Config.swift
//  Core
//
//  Created by Jake Heiser on 9/1/17.
//

import Foundation
import PathKit

public class Config {
    
    public enum Keys: String {
        case reformat
    }
    
    public struct File: Codable {
        
        public var reformat: Bool?
        
        static func from(path: Path) -> File? {
            guard let data = try? path.read(),
                let file = try? decoder.decode(File.self, from: data) else {
                    return nil
            }
            return file
        }
    }
    
    public static let defaultConfig = File(
        reformat: false
    )
    
    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return encoder
    }()
    private static let decoder = JSONDecoder()
    
    public let globalPath: Path
    public let localPath: Path
    
    public private(set) var global: File
    public private(set) var local: File
    
    init(globalPath: Path, directory: Path) {
        self.globalPath = globalPath
        self.localPath = directory + "ice.json"
        
        self.global = File.from(path: globalPath) ?? Config.defaultConfig
        self.local = File.from(path: localPath) ?? File(reformat: nil)
    }
    
    public func get(_ key: Keys) -> String {
        let val: Any
        switch key {
        case .reformat: val = get(\.reformat)
        }
        return String(describing: val)
    }
    
    public func get<T>(_ keyPath: KeyPath<File, T?>) -> T {
        if let value = local[keyPath: keyPath] {
            return value
        }
        if let value = global[keyPath: keyPath] {
            return value
        }
        return Config.defaultConfig[keyPath: keyPath]!
    }
    
    public func set<T>(_ path: WritableKeyPath<File, T?>, value: T, global setGlobal: Bool) throws {
        if setGlobal {
            global[keyPath: path] = value
            try globalPath.write(Config.encoder.encode(global))
        } else {
            local[keyPath: path] = value
            try localPath.write(Config.encoder.encode(local))
        }
    }

}
