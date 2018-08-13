//
//  Config.swift
//  Core
//
//  Created by Jake Heiser on 9/1/17.
//

import Foundation
import PathKit

public protocol ConfigType {
    var localDirectory: Path { get }
    
    var reformat: Bool { get }
    var openAfterXc: Bool { get }
}

public class Config: ConfigType {
    
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
    
    public struct File: Codable {
        
        public var reformat: Bool?
        public var openAfterXc: Bool?
        
        static func from(path: Path) -> File? {
            guard let data = try? path.read(),
                let file = try? decoder.decode(File.self, from: data) else {
                    return nil
            }
            return file
        }
    }
    
    public static let defaultConfig = File(
        reformat: false,
        openAfterXc: true
    )
    
    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return encoder
    }()
    private static let decoder = JSONDecoder()
    
    public let globalPath: Path
    public let localDirectory: Path
    public let localPath: Path
    
    public private(set) var global: File
    public private(set) var local: File
    
    public var reformat: Bool {
        return local.reformat ?? global.reformat ?? false
    }
    
    public var openAfterXc: Bool {
        return local.openAfterXc ?? global.openAfterXc ?? true
    }
    
    init(globalPath: Path, localDirectory: Path) {
        self.globalPath = globalPath
        self.localDirectory = localDirectory
        self.localPath = localDirectory + "ice.json"
        
        self.global = File.from(path: globalPath) ?? Config.defaultConfig
        self.local = File.from(path: localPath) ?? File(reformat: nil, openAfterXc: nil)
    }
    
    public enum UpdateScope {
        case local
        case global
    }
    
    public func update(scope: UpdateScope, _ go: (inout File) -> ()) throws {
        switch scope {
        case .local:
            go(&local)
            try localPath.write(Config.encoder.encode(local))
        case .global:
            go(&global)
            try globalPath.write(Config.encoder.encode(global))
        }
    }

}
