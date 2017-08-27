//
//  Global.swift
//  Ice
//
//  Created by Jake Heiser on 7/22/17.
//

import Files

class Global {

    static let directory = "/usr/local/Icebox/"

    // static func inPackage(name: String) -> Bool {
        
    // }

    enum Error: Swift.Error {
        case alreadyInstalled
    }

    static func add(name: String, version: String? = nil) throws {
        if let local = try? LocalPackage.find(name) {
            guard let version = version else {
                throw Error.alreadyInstalled
            }
            if local.versions.contains(Version(version)) {
                throw Error.alreadyInstalled
            }
            try local.install(version: Version(version))
            return
        }

        let package = try RemotePackage.resolve(name: name, version: version)
        try package.install()

        let path = Global.directory + package.name
        
        let projectFolder = try FileSystem.createFolder(at: path)
        let versionedFolderPath = projectFolder.path + "/" + package.version
        
        // Create dir
        // exec("git clone \(package.url) \(versionedFolderPath)")

        let spm = SPM(path: versionedFolderPath)
        spm.build()

        // exec("ln -s ")
    }

    static func remove(name: String) throws {
        let package = try RemotePackage.resolveLocal(name: name)

    }


}
