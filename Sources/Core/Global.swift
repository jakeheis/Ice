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

    // static func inPackage(name: String) -> Bool {
        
    // }

    enum Error: Swift.Error {
        case alreadyInstalled
    }
    
    public static func setup() throws {
        try FileSystem().createFolderIfNeeded(at: Global.directory)
    }

    public static func add(ref: RepositoryReference, version: Version? = nil) throws {
        try setup()
        
        let folder = Global.directory + ref.name
        
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

    static func remove(name: String) throws {
//        _ = try RemotePackage.resolve(name: name)

    }


}
