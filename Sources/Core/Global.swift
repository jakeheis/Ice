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

    enum Error: Swift.Error {
        case alreadyInstalled
    }
    
    public static func setup() throws {
        try FileSystem().createFolderIfNeeded(at: Global.directory)
    }

    public static func add(ref: RepositoryReference, version: Version? = nil) throws {
        try setup()
        
        let refDir: String
        if let versioned = version ?? ref.latestVersion() {
            refDir = String(describing: versioned)
        } else {
            refDir = Global.defaultDir
        }
        let folder = Global.directory + ref.name + "/\(refDir)"
        
        if (try? Folder(path: folder)) != nil {
            print("Project already downloaded")
        } else {
            let clone = Process()
            clone.launchPath = "/usr/bin/env"
            clone.arguments = ["git", "clone", ref.url, folder]
            clone.launch()
            clone.waitUntilExit()
        }
        
        let spm = SPM(path: folder)
        
        try spm.build(release: true)
        let bin = try spm.showBinPath(release: true)
        
        for file in try Folder(path: bin).files where FileManager.default.isExecutableFile(atPath: file.path) {
            try FileManager.default.createSymbolicLink(atPath : "/usr/local/bin/\(file.name)", withDestinationPath: file.path)
        }
    }

    public static func remove(name: String, purge: Bool) throws {
        let dir = Global.directory + name
        
        guard let folder = try? Folder(path: dir) else {
            throw SwiftProcess.Error.processFailed
        }
        
        if purge {
            for version in folder.subfolders {
                try version.delete()
            }
            try folder.delete()
        } else {
            let sorted = folder.subfolders.sorted { (one ,two) in
                if one.name == Global.defaultDir {
                    return false
                }
                if two.name == Global.defaultDir {
                    return true
                }
                guard let versionOne = Version(one.name), let versionTwo = Version(two.name) else {
                    fatalError("Unrecognized folder: \(one.name) \(two.name)")
                }
                return versionOne < versionTwo
            }
            
            guard let mostRecent = sorted.last else {
                throw SwiftProcess.Error.processFailed
            }
            
            try mostRecent.delete()
            if folder.subfolders.count > 1 {
                print("Removing most recent version (\(mostRecent.name)). Run --purge to remove all versions")
            } else {
                try folder.delete()
            }
        }
    }


}
