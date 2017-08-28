//
//  Global.swift
//  Ice
//
//  Created by Jake Heiser on 7/22/17.
//

// import Files

import Foundation

public class Global {

    static let directory = "/usr/local/Icebox/"

    // static func inPackage(name: String) -> Bool {
        
    // }

    enum Error: Swift.Error {
        case alreadyInstalled
    }

    public static func add(name: String, version: Version? = nil) throws {
//        let url = "https://github.com/\(name)"
//
//        let clone = Process()
////        if let local = try? LocalPackage.find(name: name) {
//            guard let version = version else {
//                throw Error.alreadyInstalled
//            }
//            if local.versions.contains(Version(version)!) {
//                throw Error.alreadyInstalled
//            }
//            local.install(version: Version(version)!)
//            return
//        }
//
//        let package = try RemotePackage.resolve(name: name, version: version)
//        try package.install()

//        let path = Global.directory + package.name
        
//        let projectFolder = try FileSystem.createFolder(at: path)
//        let versionedFolderPath = projectFolder.path + "/" + package.version
        
        // Create dir
        // exec("git clone \(package.url) \(versionedFolderPath)")

//        let spm = SPM(path: versionedFolderPath)
//        spm.build()

        // exec("ln -s ")
    }

    static func remove(name: String) throws {
//        _ = try RemotePackage.resolve(name: name)

    }


}
