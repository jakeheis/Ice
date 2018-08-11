//
//  Ice.swift
//  IcePackageDescription
//
//  Created by Jake Heiser on 9/22/17.
//

import PathKit
import SwiftCLI

public class Ice {
    
    public static let version = Version(0, 7, 0)
    public static let defaultRoot = Path.home + ".icebox"
    
    public let root: Path
    public let registry: Registry
    
    public init(root: Path = Ice.defaultRoot) throws {
        let registryDirectory = root + "Registry"
        
        self.root = root
        self.registry = Registry(registryPath: registryDirectory)
        
        if !root.exists {
            try run("mkdir", "-p", root.string)
            try run("mkdir", "-p", registryDirectory.string)
        }
        
        let versionFile = root + "version"
        if let versionString: String = try? versionFile.read(), let oldVersion = Version(versionString) {
            if oldVersion != Ice.version {
                try migrate(from: oldVersion)
                try versionFile.write(Ice.version.string)
            }
        } else {
            try versionFile.write(Ice.version.string)
        }
    }
    
    public func config(for directory: Path) -> Config {
        return Config(globalPath: root + "config.json", localDirectory: directory)
    }
    
    public func migrate(from: Version) throws {
        
    }
    
}
