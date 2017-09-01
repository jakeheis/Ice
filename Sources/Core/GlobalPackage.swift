//
//  GlobalPackage.swift
//  Core
//
//  Created by Jake Heiser on 9/1/17.
//

import Foundation
import Files

public class GlobalPackage {
    
    let name: String
    
    var path: String {
        return Global.root + name
    }
    
    lazy var spm: SPM = {
        return SPM(path: path)
    }()
    
    var exists: Bool {
        return (try? folder()) != nil
    }
    
    init(name: String) {
        self.name = name
    }
    
    func binPath() throws -> String {
        return try spm.showBinPath()
    }
    
    func folder() throws -> Folder {
        return try Folder(path: try binPath())
    }
    
    func executables() throws -> [File] {
        return try folder().files.filter { FileManager.default.isExecutableFile(atPath: $0.path) }
    }
    
    func clone(url: String, version: Version?) throws {
        do {
            try Git.clone(url: url, to: path)
        } catch let error as Exec.Error {
            throw IceError(message: "clone failed", exitStatus: error.exitStatus)
        }
    }
    
    func symlinkExecutables() throws -> Bool {
        var any = false
        for executable in try executables() {
            let path = Global.symlinkDir + executable.name
            try FileManager.default.createSymbolicLink(atPath : path, withDestinationPath: executable.path)
            any = true
        }
        return any
    }
    
    func unlinkExecutables() throws {
        for executable in try executables() {
            let potentialPath = Global.symlinkDir + executable.name
            if let destination = try? FileManager.default.destinationOfSymbolicLink(atPath: potentialPath), destination == executable.path {
                print("Unlinking \(executable.name) from \(potentialPath)")
                try FileManager.default.removeItem(atPath: potentialPath)
            }
        }
    }
    
    func delete() throws {
        try folder().delete()
    }
    
}
