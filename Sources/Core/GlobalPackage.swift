//
//  GlobalPackage.swift
//  Core
//
//  Created by Jake Heiser on 9/1/17.
//

import Foundation
import FileKit
import Exec

public class GlobalPackage {
    
    let name: String
    
    var path: Path {
        return Global.root + name
    }
    
    private lazy var spm: SPM = {
        return SPM(path: path)
    }()
    
    var exists: Bool {
        return path.exists
    }
    
    init(name: String) {
        self.name = name
    }
    
    func build() throws {
        try spm.build(release: true)
    }
    
    func clone(url: String, version: Version?) throws {
        do {
            try Git.clone(url: url, to: path.rawValue, version: version)
        } catch let error as Exec.Error {
            throw IceError(message: "clone failed", exitStatus: error.exitStatus)
        }
    }
    
    func symlinkExecutables() throws -> Bool {
        var any = false
        for executable in try executables() {
            let path = Path(Config.get(\.bin)) + executable.fileName
            try executable.symlinkFile(to: path)
            any = true
        }
        return any
    }
    
    func unlinkExecutables() throws {
        for executable in try executables() {
            let potentialPath = Path(Config.get(\.bin)) + executable.fileName
            if potentialPath.isExecutable, potentialPath.resolved == executable {
                print("Unlinking \(executable.fileName) from \(potentialPath)")
                try potentialPath.deleteFile()
            }
        }
    }
    
    func delete() throws {
        try path.deleteFile()
    }
    
    func executables() throws -> [Path] {
        let bin = try spm.showBinPath(release: true)
        return Path(bin).children().filter { $0.isExecutable && $0.pathExtension != "build" }
    }
    
}
