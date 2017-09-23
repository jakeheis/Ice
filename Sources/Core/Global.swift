//
//  Global.swift
//  Ice
//
//  Created by Jake Heiser on 7/22/17.
//

import FileKit
import Foundation

public class Global {
    
    enum Error: Swift.Error {
        case alreadyInstalled
    }
    
    let root: Path
    let config: Config
    
    init(packagesPath: Path, config: Config) {
        self.root = packagesPath
        self.config = config
    }
    
    public func add(ref: RepositoryReference, version: Version?) throws {
        let globalPackage = GlobalPackage(name: ref.name, packageRoot: root, config: config)
        
        if globalPackage.exists {
            print("Project already downloaded")
        } else {
            let cloneVersion: Version?
            if let version = version {
                cloneVersion = version
            } else {
                cloneVersion = try ref.latestVersion()
            }
            try globalPackage.clone(url: ref.url, version: cloneVersion)
        }
        
        try globalPackage.build()
        
        let anyLinked = try globalPackage.symlinkExecutables()
        
        if !anyLinked {
            print("Warning: no executables found")
        }
    }
    
    public func upgrade(name: String, version: Version?) throws {
        let packageName: String
        if let ref = RepositoryReference(name) {
            packageName = ref.name
        } else {
            packageName = name
        }
        
        let package = GlobalPackage(name: packageName, packageRoot: root, config: config)
        
        guard package.exists else {
            throw IceError(message: "\(name) not installed")
        }
        
        let ref: RepositoryReference
        if let entered = RepositoryReference(name) {
            ref = entered
        } else {
            let url: String
            do {
                url = try Git.getRemoteUrl(of: package.path.rawValue).trimmed
            } catch let error as IceError {
                throw IceError(message: "couldn't get remote url of package", exitStatus: error.exitStatus)
            }
            ref = RepositoryReference(url: url)
        }
        
        try package.unlinkExecutables()
        try package.delete()
        
        try add(ref: ref, version: version)
    }

    public func remove(name: String) throws {
        let packageName: String
        if let ref = RepositoryReference(name) {
            packageName = ref.name
        } else {
            packageName = name
        }
        
        let package = GlobalPackage(name: packageName, packageRoot: root, config: config)
        
        guard package.exists else {
            throw IceError(message: "\(name) not installed")
        }
        
        try package.unlinkExecutables()
        try package.delete()
    }


}
