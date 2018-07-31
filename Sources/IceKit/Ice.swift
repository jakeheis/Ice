//
//  Ice.swift
//  IcePackageDescription
//
//  Created by Jake Heiser on 9/22/17.
//

import PathKit
import SwiftCLI

public class Ice {
    
    public static let defaultRoot = Path.home + ".icebox"
    
    public let version = "0.6.0"
    
    public let root: Path
    public let config: Config
    public let registry: Registry
    
    public init(root: Path = Ice.defaultRoot) throws {
        let versionFile = root + "version"
        let configFile = root + "config.json"
        let registryDirectory = root + "Registry"
        
        if !root.exists {
            try run("mkdir", "-p", root.string)
            try versionFile.write(version)
            try run("mkdir", "-p", registryDirectory.string)
        }
        
        self.root = root
        self.config = Config(globalConfigPath: configFile)
        self.registry = Registry(registryPath: registryDirectory)
    }
    
}
