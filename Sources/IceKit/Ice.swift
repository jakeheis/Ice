//
//  Ice.swift
//  IcePackageDescription
//
//  Created by Jake Heiser on 9/22/17.
//

import Foundation
import PathKit

public class Ice {
    
    public static let version = "0.6.0"
    
    struct Paths {
        static let rootEnvKey = "ICE_GLOBAL_ROOT"
        static let root: Path = {
            if let root = ProcessInfo.processInfo.environment[rootEnvKey] {
                return Path(root)
            }
            return Path.home + ".icebox"
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
    
    private static func setup() {
        if Paths.root.exists {
            return
        }
        do {
            try Paths.root.mkpath()
            try Paths.versionFile.write(version)
            try Paths.packagesDirectory.mkpath()
            try Paths.registryDirectory.mkpath()
        } catch {
            niceFatalError("couldn't set up Ice at \(Paths.root)")
        }
    }
    
}
