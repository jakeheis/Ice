//
//  Config.swift
//  Core
//
//  Created by Jake Heiser on 9/1/17.
//

import Foundation
import PathKit

public struct ConfigFile: Codable {
    public var reformat: Bool?
    public var openAfterXc: Bool?
}

public struct Config {
    
    public enum Keys: String {
        case reformat
        case openAfterXc
        
        public var shortDescription: String {
            switch self {
            case .reformat: return "whether Ice should organize your Package.swift (alphabetize, etc.); defaults to false"
            case .openAfterXc: return "whether Ice should open Xcode the generated project after running `ice xc`; defaults to true"
            }
        }
        
        public static var all: [Keys] = [.reformat, openAfterXc]
    }
    
    public static func load(for directory: Path) -> Config {
        return ConfigManager(global: Ice.defaultRoot, local: directory).resolved
    }
    
    public let reformat: Bool
    public let openAfterXc: Bool
    
    public init(reformat: Bool? = nil, openAfterXc: Bool? = nil) {
        self.reformat = reformat ?? false
        self.openAfterXc = openAfterXc ?? true
    }
    
    public init(file: ConfigFile) {
        self.init(reformat: file.reformat, openAfterXc: file.openAfterXc)
    }
    
    public init(prioritized files: [ConfigFile]) {
        self.init(
            reformat: files.first(where: { $0.reformat != nil })?.reformat,
            openAfterXc: files.first(where: { $0.openAfterXc != nil })?.openAfterXc
        )
    }
    
}

public class ConfigManager {
    
    public let globalPath: Path
    public let localPath: Path
    
    public private(set) var global: ConfigFile
    public private(set) var local: ConfigFile
    
    public var resolved: Config {
        return Config(prioritized: [local, global])
    }
    
    public init(global: Path, local: Path) {
        self.globalPath = global + "config.json"
        self.localPath = local + "ice.json"
        
        self.global = ConfigFile.load(from: globalPath) ?? .init()
        self.local = ConfigFile.load(from: localPath) ?? .init()
    }
    
    public enum UpdateScope {
        case local
        case global
    }
    
    public func update(scope: UpdateScope, _ go: (inout ConfigFile) -> ()) throws {
        switch scope {
        case .local:
            go(&local)
            try localPath.write(JSON.encoder.encode(local))
        case .global:
            go(&global)
            try globalPath.write(JSON.encoder.encode(global))
        }
    }
    
}
