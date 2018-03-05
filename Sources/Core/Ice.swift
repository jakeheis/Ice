//
//  Ice.swift
//  IcePackageDescription
//
//  Created by Jake Heiser on 9/22/17.
//

import Foundation
import FileKit
import Exec

public class Ice {
    
    public static let version = "0.3.0"
    
    struct Paths {
        
        static let rootEnvKey = "ICE_GLOBAL_ROOT"
        static let root: Path = {
            if let root = ProcessInfo.processInfo.environment[rootEnvKey] {
                return Path(root)
            }
            return Path.userHome + ".icebox"
        }()
        
        static let versionFile = root + "version"
        static let globalConfigFile = root + "config.json"
        static let packagesDirectory = root + "Packages"
        static let registryDirectory = root + "Registry"

        private init() {}
    }
    
    public static let config: Config = {
        setup()
        return Config(globalConfigPath: Paths.globalConfigFile)
    }()
    
    public static let registry: Registry = {
        setup()
        return Registry(registryPath: Paths.registryDirectory)
    }()
    
    public static let global: Global = {
        setup()
        return Global(packagesPath: Paths.packagesDirectory, config: config)
    }()
    
    public static func setup() {
        if Paths.root.exists {
            return
        }
        do {
            try Paths.root.createDirectory(withIntermediateDirectories: true)
            try version.write(to: Paths.versionFile)
            try Paths.packagesDirectory.createDirectory(withIntermediateDirectories: true)
            try Paths.registryDirectory.createDirectory(withIntermediateDirectories: true)
        } catch {
            niceFatalError("Couldn't set up Ice at \(Paths.root)")
        }
    }
    
}
