//
//  Config.swift
//  Core
//
//  Created by Jake Heiser on 9/1/17.
//

import Foundation
import FileKit

public class Config {
    
    let globalPath: Path
    
    public private(set) var globalConfig: ConfigFile?
    
    init(globalConfigPath: Path) {
        globalPath = globalConfigPath
        globalConfig = ConfigFile.from(path: globalPath)
    }
    
    public func get<T>(_ keyPath: KeyPath<ConfigFile, T?>, directory: Path = Path.current) -> T {
        if let localConfig = ConfigFile.from(path: directory + "ice.json"), let value = localConfig[keyPath: keyPath] {
            return value
        }
        if let globalConfig = globalConfig, let value = globalConfig[keyPath: keyPath] {
            return value
        }
        return ConfigFile.defaultConfig[keyPath: keyPath]!
    }
    
    public func set<T>(_ path: WritableKeyPath<ConfigFile, T?>, value: T) throws {
        var file: ConfigFile
        if let existing = self.globalConfig {
            file = existing
        } else {
            let new = ConfigFile(reformat: nil)
            file = new
        }
        
        file[keyPath: path] = value
        
        self.globalConfig = file
        
        try ConfigFile.encoder.encode(file).write(to: globalPath)
    }
    
}

public struct ConfigFile: Codable {
    
    public static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return encoder
    }()
    public static let decoder = JSONDecoder()
    
    public static let defaultConfig = ConfigFile(
        reformat: false
    )
    
    public enum Keys: String {
        case reformat
    }
    
    public var reformat: Bool?
    
    public static func layer(config: ConfigFile?, onto: ConfigFile) -> ConfigFile {
        return ConfigFile(reformat: config?.reformat ?? onto.reformat)
    }
    
    static func from(path: Path) -> ConfigFile? {
        guard let data = try? Data.read(from: path),
            let file = try? decoder.decode(ConfigFile.self, from: data) else {
            return nil
        }
        return file
    }
    
}

