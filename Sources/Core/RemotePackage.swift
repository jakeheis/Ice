
//
//  RemotePackage.swift
//  Ice
//
//  Created by Jake Heiser on 7/21/17.
//

import Files

struct PackageInstaller {

    static func install(url: String, destination: String) throws {
        // git clone \(url) \(destination)

        let spm = SPM(path: destination)
        spm.build()
    }

}

struct LocalPackage {

    let name: String
    let url: String
    let versions: [Version]

    var folder: Folder {
        
    }

    static func find(name: String) throws -> LocalPackage {

    }

    func install(version: Version) {
        try PackageInstaller.install(url: url, destination: folder.path + version)
    }

}

struct RemotePackage {

    let name: String
    let url: String
    let version: String

    static func resolve(name: String, version: String? = nil) throws -> RemotePackage {
        let fullUrl = "https://github.com/\(name)"
        if package.dependencies.contains(where: { $0.url == fullUrl }) {
            print("Dependency already exists")
            throw SPM.Error.processFailed
        }
        
        var major: Int?
        var minor: Int?
        
        if let tagUrl = URL(string: "https://api.github.com/repos/\(dependency)/tags") {
            let (data, _, _) = URLSession.synchronousDataTask(with: tagUrl)
            if let data = data,
                let tags = try? JSONDecoder().decode([RepositoryTag].self, from: data) {
                let versions = tags.flatMap { Version.init($0.name) }.filter { $0.patch.index(of: "-") == nil }.sorted()
                if let mostRecent = versions.last {
                    major = mostRecent.major
                    minor = mostRecent.minor
                }
            }
        }
        
        if major == nil {
            print("Major version:", terminator: "")
            major = Int(readLine()!)
            print("Minor version (blank for any):", terminator: "")
            minor = Int(readLine()!)
        }
    }

    func install() throws -> LocalPackage {

    }

}