//
//  Config.swift
//  Core
//
//  Created by Jake Heiser on 9/1/17.
//

import Foundation
import PathKit

public protocol ConfigType {
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
                let file = try? JSON.decoder.decode(File.self, from: data) else {
                    return nil
            }
            return file
        }
    }
    
    public static let `default`: ConfigType = DefaultConfig()
    
    public let globalPath: Path
    public let localPath: Path
    
    public private(set) var global: File
    public private(set) var local: File
    
    public var reformat: Bool {
        return local.reformat ?? global.reformat ?? Config.default.reformat
    }
    
    public var openAfterXc: Bool {
        return local.openAfterXc ?? global.openAfterXc ?? Config.default.openAfterXc
    }
    
    public init(globalPath: Path, localDirectory: Path) {
        self.globalPath = globalPath
        self.localPath = localDirectory + "ice.json"
        
        self.global = File.from(path: globalPath) ?? File(
            reformat: Config.default.reformat,
            openAfterXc: Config.default.openAfterXc
        )
        self.local = File.from(path: localPath) ?? File(
            reformat: nil,
            openAfterXc: nil
        )
    }
    
    public enum UpdateScope {
        case local
        case global
    }
    
    public func update(scope: UpdateScope, _ go: (inout File) -> ()) throws {
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

private class DefaultConfig: ConfigType {
    let reformat = false
    let openAfterXc = true
}
