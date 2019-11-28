//
//  Ice.swift
//  IcePackageDescription
//
//  Created by Jake Heiser on 9/22/17.
//

import PathKit
import SwiftCLI

public class Ice {
    
    public static let version = Version(0, 9, 0)
    public static let defaultRoot = Path.home + ".icebox"
    
    public let root: Path
    public let registry: Registry
    
    public init?(root: Path = Ice.defaultRoot) {
        let registryDirectory = root + "Registry"
        
        self.root = root
        self.registry = Registry(registryPath: registryDirectory)
        
        do {
            if !root.exists {
                try Task.run("mkdir", "-p", root.string)
                try Task.run("mkdir", "-p", registryDirectory.string)
            }
            
            let versionFile = root + "version"
            if let versionString: String = try? versionFile.read().trimmingCharacters(in: .whitespacesAndNewlines),
                let oldVersion = Version(versionString) {
                if oldVersion != Ice.version {
                    try migrate(from: oldVersion)
                    try versionFile.write(Ice.version.string)
                }
            } else {
                try versionFile.write(Ice.version.string)
            }
        } catch {
            return nil
        }
    }
    
    public func config(for directory: Path) -> ConfigManager {
        return .init(global: root, local: directory)
    }
    
    public func migrate(from: Version) throws {
        if from < Version(0, 7, 0) {
            // Starting in 0.7.0, the local registry is pretty printed so that it can be grepped in completion generator
            try registry.write()
        }
    }
    
}
