//
//  Global.swift
//  Ice
//
//  Created by Jake Heiser on 7/22/17.
//

import Foundation
import Files

public class Global {

    static let directory = FileSystem().homeFolder.path + ".icebox/"
    static let defaultDir = "default"
//    static let symlinkPath = "/usr/local/bin/"
    static let symlinkPath = directory + "bin/"
    
    enum Error: Swift.Error {
        case alreadyInstalled
    }
    
    public static func setup() throws {
        try FileSystem().createFolderIfNeeded(at: Global.directory)
        try FileSystem().createFolderIfNeeded(at: Global.symlinkPath)
    }

    private static func path(to package: String) -> String {
        return directory + package;
    }
    
    public static func add(ref: RepositoryReference, version: Version?) throws {
        try setup()
        
        let refDir: String
        if let version = version {
            refDir = version.raw
        } else if let latest = try ref.latestVersion() {
            refDir = latest.raw
        } else {
            refDir = Global.defaultDir
        }
        let folder = path(to: ref.name) + "/\(refDir)"
        
        if (try? Folder(path: folder)) != nil {
            print("Project already downloaded")
            return
        } else {
            do {
                try Git.clone(url: ref.url, to: folder)
            } catch let error as IceError {
                throw IceError(message: "clone failed", exitStatus: error.exitStatus)
            }
        }
        let spm = try SPM(path: folder)
        try spm.build(release: true)
        
        let any = try addExecutables(at: folder)
        if !any {
            print("Warning: no executables found")
        }
        
        try FileManager.default.createSymbolicLink(atPath : path(to: ref.name) + "/current", withDestinationPath: folder)
    }
    
    @discardableResult
    private static func iterateExecutables(of spm: SPM, each: (_ executable: File) throws -> ()) throws -> Bool {
        let bin = try spm.showBinPath(release: true)
        var any = false
        for file in try Folder(path: bin).files where FileManager.default.isExecutableFile(atPath: file.path) {
            try each(file)
            any = true
        }
        return any
    }
    
    @discardableResult
    private static func addExecutables(at path: String) throws -> Bool {
        let spm = try SPM(path: path)
        return try iterateExecutables(of: spm) { (executable) in
            let path = Global.symlinkPath + executable.name
            print("Linking \(executable.name) to \(path)")
            try FileManager.default.createSymbolicLink(atPath : path, withDestinationPath: executable.path)
        }
    }
    
    private static func removeExecutables(at path: String) throws {
        let spm = try SPM(path: path)
        try iterateExecutables(of: spm) { (executable) in
            let potentialPath = Global.symlinkPath + executable.name
            if let destination = try? FileManager.default.destinationOfSymbolicLink(atPath: potentialPath), destination == executable.path {
                print("Unlinking \(executable.name) from \(potentialPath)")
                try FileManager.default.removeItem(atPath: potentialPath)
            }
        }
    }
    
    public static func upgrade(name: String, version: Version?) throws {
        guard let project = try? Folder(path: path(to: name)), let current = try? project.subfolder(named: "current") else {
            throw IceError(message: "\(name) not already installed")
        }
        
        let ref: RepositoryReference
        if let entered = RepositoryReference(name) {
            ref = entered
        } else {
            let url: String
            do {
                url = try Git.getRemoteUrl(of: current.path).trimmed
            } catch let error as IceError {
                throw IceError(message: "couldn't get remote url of package", exitStatus: error.exitStatus)
            }
            ref = RepositoryReference(url: url)
        }
        
        var installVersion: Version? = version
        if installVersion == nil {
            installVersion = try ref.latestVersion()
        }
        if let installVersion = installVersion {
            if project.containsSubfolder(named: installVersion.raw) {
                throw IceError(message: "already donwloaded version \(installVersion)")
            }
        }
        
        try removeExecutables(at: current.path)
        
        try add(ref: ref, version: installVersion)
    }

    public static func remove(name: String, purge: Bool) throws {
        let packageName: String
        if let ref = RepositoryReference(name) {
            packageName = ref.name
        } else {
            packageName = name
        }
        
        let dir = Global.directory + packageName
        
        guard let folder = try? Folder(path: dir) else {
            throw IceError(message: "\(name) not installed")
        }
        
        if let mostRecent = try? folder.subfolder(named: "current") {
            print("Removing executables")
            try removeExecutables(at: mostRecent.path)
        }
        
        print("Removing project folder")
        try folder.delete()
    }


}
