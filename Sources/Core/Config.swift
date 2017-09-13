//
//  Config.swift
//  Core
//
//  Created by Jake Heiser on 9/1/17.
//

import Foundation
import FileKit

public class Config {
    
    public static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return encoder
    }()
    
    private static let localPath = Path.current + "ice.json"
    private static let globalPath = Global.root + "ice.json"
    
    public static let localConfig = ConfigFile.from(path: localPath)
    private(set) public static var globalConfig = ConfigFile.from(path: globalPath)
    
    public static let defaultConfig = ConfigFile(
        bin: (Global.root + "bin").rawValue,
        strict: false
    )
    
    public static func get<T>(_ path: KeyPath<ConfigFile, T?>) -> T {
        if let localConfig = localConfig, let value = localConfig[keyPath: path] {
            return value
        }
        if let globalConfig = globalConfig, let value = globalConfig[keyPath: path] {
            return value
        }
        return defaultConfig[keyPath: path]!
    }
    
    public static func set<T>(_ path: WritableKeyPath<ConfigFile, T?>, value: T) throws {
        var file: ConfigFile
        if let existing = self.globalConfig {
            file = existing
        } else {
            try Global.setup()
            
            let new = ConfigFile(bin: nil, strict: nil)
            file = new
        }
        
        file[keyPath: path] = value
        
        self.globalConfig = file
        
        try encoder.encode(file).write(to: globalPath)
    }
    
    public static func layer(config: ConfigFile?, onto: ConfigFile) -> ConfigFile {
        return ConfigFile(bin: config?.bin ?? onto.bin, strict: config?.strict ?? onto.strict)
    }
    
}

public struct ConfigFile: Codable {
    
    public var bin: String?
    public var strict: Bool?
    
    static func from(path: Path) -> ConfigFile? {
        guard let data = try? Data.read(from: path),
            let file = try? JSONDecoder().decode(ConfigFile.self, from: data) else {
            return nil
        }
        return file
    }
    
}

