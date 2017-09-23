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
    public let localConfig: ConfigFile?
    public private(set) var globalConfig: ConfigFile?
    public let defaultConfig = ConfigFile(
        bin: (Global.root + "bin").rawValue,
        strict: false
    )
    
    init(globalRoot: Path) {
        globalPath = globalRoot + "config.json"
        localConfig = ConfigFile.from(path: Path.current + "ice.json")
        globalConfig = ConfigFile.from(path: globalPath)
    }
    
    public func get<T>(_ path: KeyPath<ConfigFile, T?>) -> T {
        if let localConfig = localConfig, let value = localConfig[keyPath: path] {
            return value
        }
        if let globalConfig = globalConfig, let value = globalConfig[keyPath: path] {
            return value
        }
        return defaultConfig[keyPath: path]!
    }
    
    public func set<T>(_ path: WritableKeyPath<ConfigFile, T?>, value: T) throws {
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
        
        try ConfigFile.encoder.encode(file).write(to: globalPath)
    }
    
}

public struct ConfigFile: Codable {
    
    public static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return encoder
    }()
    public static let decoder: JSONDecoder = {
        return JSONDecoder()
    }()
    
    public var bin: String?
    public var strict: Bool?
    
    public static func layer(config: ConfigFile?, onto: ConfigFile) -> ConfigFile {
        return ConfigFile(bin: config?.bin ?? onto.bin, strict: config?.strict ?? onto.strict)
    }
    
    static func from(path: Path) -> ConfigFile? {
        guard let data = try? Data.read(from: path),
            let file = try? decoder.decode(ConfigFile.self, from: data) else {
            return nil
        }
        return file
    }
    
}

